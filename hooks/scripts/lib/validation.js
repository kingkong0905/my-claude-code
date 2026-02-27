/**
 * Shared input helpers for hook scripts.
 * Reads the JSON payload Claude Code sends to hook scripts via stdin.
 */

/**
 * Read and parse the tool input from stdin.
 * @returns {Promise<Record<string, unknown>>}
 */
export async function readToolInput() {
  return new Promise((resolve) => {
    const chunks = [];
    process.stdin.on("data", (chunk) => chunks.push(chunk));
    process.stdin.on("end", () => {
      try {
        resolve(JSON.parse(Buffer.concat(chunks).toString()));
      } catch {
        resolve({});
      }
    });
    process.stdin.on("error", () => resolve({}));
  });
}
