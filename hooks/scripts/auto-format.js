#!/usr/bin/env node
/**
 * PostToolUse[Edit|Write] hook
 * Auto-formats files after edits using the appropriate formatter.
 */

import { execSync } from "child_process";
import { readFileSync, existsSync } from "fs";
import { extname } from "path";

let input;
try {
  input = JSON.parse(readFileSync("/dev/stdin", "utf8"));
} catch {
  process.exit(0);
}

const filePath = input?.tool_input?.file_path;
if (!filePath || !existsSync(filePath)) process.exit(0);

const ext = extname(filePath);

const formatters = {
  ".js": ["prettier", "--write"],
  ".ts": ["prettier", "--write"],
  ".jsx": ["prettier", "--write"],
  ".tsx": ["prettier", "--write"],
  ".json": ["prettier", "--write"],
  ".md": ["prettier", "--write"],
  ".py": ["ruff", "format"],
  ".go": ["gofmt", "-w"],
  ".rb": ["rubocop", "-A"],
};

const formatter = formatters[ext];
if (!formatter) process.exit(0);

try {
  execSync(`${formatter.join(" ")} "${filePath}"`, {
    stdio: "ignore",
    timeout: 10000,
  });
} catch {
  // Formatter not installed or failed — silently skip
}

process.exit(0);
