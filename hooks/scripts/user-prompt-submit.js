#!/usr/bin/env node
/**
 * UserPromptSubmit hook
 * Injects useful context into every prompt (git branch, dirty state).
 */

import { execSync } from "child_process";

function getGitContext() {
  try {
    const branch = execSync("git rev-parse --abbrev-ref HEAD", {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "ignore"],
    }).trim();

    const status = execSync("git status --porcelain", {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "ignore"],
    }).trim();

    const changedCount = status ? status.split("\n").length : 0;

    return { branch, changedCount };
  } catch {
    return null;
  }
}

const ctx = getGitContext();
if (ctx) {
  const lines = [`Current branch: ${ctx.branch}`];
  if (ctx.changedCount > 0) {
    lines.push(`${ctx.changedCount} uncommitted changes`);
  } else {
    lines.push("Working tree clean");
  }
  process.stdout.write(lines.join("\n") + "\n");
}
