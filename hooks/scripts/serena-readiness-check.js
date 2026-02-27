#!/usr/bin/env node
/**
 * PreToolUse hook — Serena Readiness Check
 *
 * Fires before any Serena MCP tool call. Checks whether the Serena index is ready
 * and surfaces status as additional context so Claude knows to wait or use alternatives.
 *
 * Adapted from https://github.com/Thinkei/eh-claude-code (CommonJS → ESM).
 * Tool name matching broadened to handle all Serena server naming variants:
 *   mcp__serena__*  |  mcp__plugin_kkclaude_serena__*  |  mcp__plugin_eh_serena__*
 */

import { existsSync, readdirSync, readFileSync, writeFileSync } from "fs";
import { execSync } from "child_process";
import { readToolInput } from "./lib/validation.js";

const pass = () => {
  process.stdout.write('{"continue": true}\n');
  process.exit(0);
};

let input;
try {
  input = await readToolInput();
} catch {
  pass();
}

const toolName = input?.tool_name ?? "";
const command = input?.tool_input?.command ?? "";

// Run for:
//   1. Native Claude Code MCP tool calls  — tool_name contains "serena"
//   2. Bash mcporter calls targeting serena — e.g. `npx mcporter call serena.*`
const isSerenaCall =
  toolName.includes("serena") ||
  (toolName === "Bash" &&
    command.includes("mcporter") &&
    command.includes("serena"));

if (!isSerenaCall) {
  pass();
}

let serenaReady = false;
let serenaNewlyReady = false;

// Check if Serena cache exists with .pkl files
if (existsSync(".serena/cache")) {
  try {
    const files = readdirSync(".serena/cache");
    const hasPklFiles = files.some((f) => f.endsWith(".pkl"));

    if (hasPklFiles) {
      serenaReady = true;

      // Notify once — write a marker file so this message only fires on first readiness
      const markerFile = ".serena/.notified";
      if (!existsSync(markerFile)) {
        serenaNewlyReady = true;
        try {
          writeFileSync(markerFile, "", "utf8");
        } catch {
          // Ignore write errors
        }
      }
    }
  } catch {
    // Ignore directory read errors
  }
}

if (serenaNewlyReady) {
  let cacheSize = "unknown";
  try {
    cacheSize = execSync("du -sh .serena/cache 2>/dev/null", {
      encoding: "utf8",
      stdio: "pipe",
    })
      .split("\t")[0]
      .trim();
  } catch {
    // Ignore
  }

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        additionalContext: `Serena indexing complete! Index size: ${cacheSize}. You can now use find_symbol, find_referencing_symbols, rename_symbol for precise semantic code navigation.`,
      },
    }) + "\n",
  );
  process.exit(0);
}

if (!serenaReady) {
  let indexingInProgress = false;

  if (existsSync(".serena/index.pid")) {
    try {
      const pid = parseInt(
        readFileSync(".serena/index.pid", "utf8").trim(),
        10,
      );
      if (pid) {
        try {
          process.kill(pid, 0); // Signal 0 checks liveness without killing
          indexingInProgress = true;
        } catch {
          // Process not alive
        }
      }
    } catch {
      // Ignore read errors
    }
  }

  const additionalContext = indexingInProgress
    ? "Serena is still indexing. Use Grep or Glob as alternatives while waiting. Monitor: tail -f .serena/logs/indexing.txt"
    : "Serena index not available. Use Grep, Glob, or search_for_pattern for code navigation instead.";

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: { hookEventName: "PreToolUse", additionalContext },
    }) + "\n",
  );
  process.exit(0);
}

pass();
