#!/usr/bin/env node
/**
 * SessionStart hook
 * Outputs context information at the start of each session.
 * Enriches with in-progress Jira tickets via mcporter (silently skipped if unavailable).
 *
 * Cloud ID resolution order:
 *   1. ATLASSIAN_CLOUD_ID env var (fastest — set once in ~/.zshrc)
 *   2. getAccessibleAtlassianResources — auto-select if single workspace
 *   3. Interactive prompt if multiple workspaces (TTY only)
 */

import { execSync } from "child_process";
import { createInterface } from "readline/promises";
import { callMcp } from "./lib/mcp.js";

function safeExec(cmd) {
  try {
    return execSync(cmd, {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "ignore"],
    }).trim();
  } catch {
    return null;
  }
}

const branch = safeExec("git rev-parse --abbrev-ref HEAD");
const lastCommit = safeExec("git log --oneline -1");

const lines = ["Session started"];
if (branch) lines.push(`Branch: ${branch}`);
if (lastCommit) lines.push(`Last commit: ${lastCommit}`);

// --- Resolve Atlassian Cloud ID ---
let cloudId = process.env.ATLASSIAN_CLOUD_ID ?? null;

if (!cloudId) {
  try {
    const resourcesResult = await callMcp(
      "atlassian",
      "getAccessibleAtlassianResources",
      {},
      3000,
    );
    const resources = resourcesResult?.json() ?? [];

    if (resources.length === 1) {
      // Single workspace — use automatically
      cloudId = resources[0].id;
      lines.push(`Atlassian workspace: ${resources[0].name}`);
    } else if (resources.length > 1) {
      if (process.stdin.isTTY) {
        // Interactive selection
        process.stderr.write("\nMultiple Atlassian workspaces found:\n");
        resources.forEach((r, i) => {
          process.stderr.write(`  ${i + 1}. ${r.name} (${r.id})\n`);
        });

        const rl = createInterface({
          input: process.stdin,
          output: process.stderr,
        });
        const answer = await rl.question(
          `Select workspace [1–${resources.length}]: `,
        );
        rl.close();

        const idx = Math.max(
          0,
          Math.min(parseInt(answer || "1", 10) - 1, resources.length - 1),
        );
        cloudId = resources[idx].id;
        lines.push(`Atlassian workspace: ${resources[idx].name}`);
        process.stderr.write(
          `\nTip: export ATLASSIAN_CLOUD_ID=${cloudId} in ~/.zshrc to skip this prompt.\n`,
        );
      } else {
        // Non-interactive — surface list as context so Claude can prompt the user
        lines.push(
          "\nMultiple Atlassian workspaces — set ATLASSIAN_CLOUD_ID to one of:",
        );
        resources.forEach((r) => lines.push(`  ${r.name}: ${r.id}`));
      }
    }
  } catch {
    // mcporter not installed, Atlassian not authenticated, or timed out — skip
  }
}

// --- Enrich with in-progress Jira tickets ---
// Fires once per session so latency is acceptable. Skipped if cloudId could not be resolved.
if (cloudId) {
  try {
    const result = await callMcp(
      "atlassian",
      "searchJiraIssuesUsingJql",
      {
        cloudId,
        jql: 'assignee = currentUser() AND status = "In Progress" ORDER BY updated DESC',
        maxResults: 5,
      },
      3000,
    );
    const issues = result?.json()?.issues ?? [];
    if (issues.length > 0) {
      lines.push(`\nIn-progress Jira tickets (${issues.length}):`);
      for (const issue of issues) {
        lines.push(`  ${issue.key}: ${issue.fields?.summary}`);
      }
    }
  } catch {
    // Jira fetch failed — skip
  }
}

process.stdout.write(lines.join("\n") + "\n");
