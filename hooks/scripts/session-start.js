#!/usr/bin/env node
/**
 * SessionStart hook
 * Outputs context information at the start of each session.
 */

import { execSync } from "child_process";

function safeExec(cmd) {
  try {
    return execSync(cmd, { encoding: "utf8", stdio: ["pipe", "pipe", "ignore"] }).trim();
  } catch {
    return null;
  }
}

const branch = safeExec("git rev-parse --abbrev-ref HEAD");
const lastCommit = safeExec("git log --oneline -1");

const lines = [`Session started`];
if (branch) lines.push(`Branch: ${branch}`);
if (lastCommit) lines.push(`Last commit: ${lastCommit}`);

process.stdout.write(lines.join("\n") + "\n");
