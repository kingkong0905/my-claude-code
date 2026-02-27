#!/usr/bin/env node
/**
 * SessionStart hook
 * Outputs context information at the start of each session.
 * Enriches with in-progress Jira tickets via mcporter (silently skipped if unavailable).
 */

import { execSync } from "child_process";
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

// Enrich with in-progress Jira tickets — fires once per session so latency is acceptable.
// Silently skipped if Atlassian is not authenticated or mcporter is unavailable.
try {
  const result = await callMcp(
    "atlassian",
    "searchJiraIssuesUsingJql",
    {
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
  // mcporter not installed, Atlassian not authenticated, or timed out — skip
}

process.stdout.write(lines.join("\n") + "\n");
