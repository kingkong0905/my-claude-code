/**
 * Lightweight mcporter wrapper for hook scripts.
 *
 * MCP servers are auto-discovered from .mcp.json via the claude-code import
 * in config/mcporter.json. No extra configuration needed.
 *
 * Usage:
 *   import { callMcp } from './lib/mcp.js';
 *   const result = await callMcp('atlassian', 'searchJiraIssuesUsingJql', { jql: '...' });
 *   const issues = result.json()?.issues ?? [];
 *
 * Keep calls out of PreToolUse/PostToolUse hooks — those fire on every tool call
 * and MCP round-trips are too slow. Use in SessionStart or UserPromptSubmit only.
 */

import { callOnce } from "mcporter";

/**
 * Call an MCP tool once and return the result.
 *
 * @param {string} server    - Server name as defined in .mcp.json (e.g. "atlassian")
 * @param {string} toolName  - Tool name exposed by the server (e.g. "searchJiraIssuesUsingJql")
 * @param {Record<string, unknown>} args - Tool arguments
 * @param {number} [timeoutMs=3000]      - Abort after this many ms (default 3 s)
 * @returns {Promise<import('mcporter').CallResult>}
 */
export async function callMcp(server, toolName, args = {}, timeoutMs = 3000) {
  const call = callOnce({ server, toolName, args });
  const timeout = new Promise((_, reject) =>
    setTimeout(
      () =>
        reject(
          new Error(
            `mcporter: ${server}.${toolName} timed out after ${timeoutMs}ms`,
          ),
        ),
      timeoutMs,
    ),
  );
  return Promise.race([call, timeout]);
}
