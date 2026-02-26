#!/usr/bin/env node
/**
 * PreToolUse[Bash] hook
 * Blocks dangerous shell commands before they execute.
 */

import { readFileSync } from "fs";

const BLOCKED_PATTERNS = [
  /rm\s+-rf\s+\/(?!\S)/,         // rm -rf /
  /rm\s+-rf\s+~\b/,              // rm -rf ~
  />\s*\/dev\/sd[a-z]/,          // overwrite block devices
  /mkfs\./,                       // format filesystems
  /dd\s+.*of=\/dev\//,           // dd to block device
];

let input;
try {
  input = JSON.parse(readFileSync("/dev/stdin", "utf8"));
} catch {
  process.exit(0);
}

const command = input?.tool_input?.command || "";

for (const pattern of BLOCKED_PATTERNS) {
  if (pattern.test(command)) {
    console.error(`Blocked dangerous command: ${command}`);
    process.exit(1);
  }
}

process.exit(0);
