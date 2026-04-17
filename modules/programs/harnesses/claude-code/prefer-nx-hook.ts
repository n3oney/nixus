#!/usr/bin/env bun
// PreToolUse hook: steer workspace-filtered package-manager runs toward nx.
//
// Reads the Claude Code hook payload on stdin. Inside an nx workspace (an
// nx.json above cwd + a runnable nx), a command like `pnpm --filter app build`
// is denied with the `nx build app` equivalent. Everything else — including any
// command carrying the NO_NX=1 bypass marker, or anything outside an nx
// workspace — prints nothing and exits 0, so it runs untouched.

import { existsSync, readFileSync } from "node:fs";
import { basename, dirname, join, resolve } from "node:path";

const allow = (): never => process.exit(0);
function deny(reason: string): never {
  console.log(
    JSON.stringify(
      {
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: reason,
        },
      },
      null,
      2,
    ),
  );
  process.exit(0);
}

interface Payload {
  tool_input?: { command?: string };
  cwd?: string;
}

// Package-manager subcommands that manage deps, not run targets — nx doesn't
// replace these, so never intercept them.
const NATIVE = new Set([
  "install",
  "i",
  "add",
  "remove",
  "rm",
  "update",
  "up",
  "upgrade",
  "dlx",
  "exec",
  "why",
  "outdated",
  "store",
  "link",
  "unlink",
  "audit",
  "publish",
  "pack",
  "init",
  "create",
  "config",
  "list",
  "ls",
  "prune",
  "dedupe",
  "patch",
  "fetch",
  "import",
  "rebuild",
  "setup",
  "env",
]);

// Wrapper words that precede the real target (`pnpm run build` -> `build`).
const RUN_WRAPPERS = new Set(["run", "run-script"]);

function findNxRoot(start: string): string | null {
  let dir = start;
  for (;;) {
    if (existsSync(join(dir, "nx.json"))) return dir;
    const parent = dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

// Best-effort nx project name for a directory: its project.json `name` if
// present (authoritative), otherwise the directory basename (the convention).
function resolveProject(dir: string): string {
  try {
    const p = join(dir, "project.json");
    if (existsSync(p)) {
      const name = JSON.parse(readFileSync(p, "utf8")).name;
      if (typeof name === "string" && name) return name;
    }
  } catch {
    // malformed project.json — fall through to the basename
  }
  return basename(dir);
}

// Extract { project, target } from a package-manager command, or null. project
// comes from a selector flag (--filter/-F/--workspace/-w, or `yarn workspace
// <proj>`) and may be "" — the caller derives it from a `cd` prefix instead.
function parse(tokens: string[]): { project: string; target: string } | null {
  if (!["pnpm", "npm", "yarn"].includes(tokens[0])) return null;

  let project = "";
  const positionals: string[] = [];

  for (let i = 1; i < tokens.length; i++) {
    const tok = tokens[i];
    const flag = /^(--filter|-F|--workspace|-w)(?:=(.*))?$/.exec(tok);
    if (flag)
      project = flag[2] ?? tokens[++i] ?? ""; // value is inline or next token
    else if (tok === "workspace")
      project = tokens[++i] ?? ""; // yarn workspace <proj>
    else if (tok.startsWith("-"))
      continue; // other flag
    else if (!RUN_WRAPPERS.has(tok)) positionals.push(tok); // skip run/run-script
  }

  const target = positionals[0] ?? "";
  if (!target || NATIVE.has(target)) return null;
  return { project, target };
}

const payload: Payload = JSON.parse(await Bun.stdin.text());
const cmd = payload.tool_input?.command ?? "";
const baseCwd = payload.cwd ?? process.cwd();
const trimmed = cmd.replace(/^\s+/, "");

// Explicit opt-out: `NO_NX=1 pnpm --filter ...` runs as-is.
if (/(^|\s)NO_NX=(1|true)\b/.test(cmd)) allow();

const nxRoot = findNxRoot(baseCwd);
if (!nxRoot) allow();
if (Bun.which("nx") === null && !existsSync(join(nxRoot, "node_modules/.bin/nx"))) allow();

// Peel an optional `cd <dir> &&` prefix — its target dir names the project —
// then look at just the head of the command, before any pipe/redirect/chain.
let cdDir: string | null = null;
let rest = trimmed;
const cd = /^cd\s+(\S+)\s*&&\s*/.exec(rest);
if (cd) {
  cdDir = cd[1];
  rest = rest.slice(cd[0].length);
}
const head = rest.split(/\s*(?:\||;|&&|\d*>|>>)\s*/)[0].trim();
if (/[;&|]/.test(head)) allow(); // still compound after peeling: leave it alone

const parsed = parse(head.split(/\s+/));
if (!parsed) allow();

// Project: an explicit --filter wins, else derive it from the `cd` target dir.
const project = parsed.project || (cdDir ? resolveProject(resolve(baseCwd, cdDir)) : "");
if (!project) allow(); // no project signal — don't guess

const nxCmd = `nx ${parsed.target} ${project}`;
deny(
  `This is an nx workspace — prefer nx over running a package manager directly. ` +
    `Use \`${nxCmd}\` instead of \`${trimmed}\`. ` +
    `If you genuinely need the package manager directly, prepend \`NO_NX=1 \`.`,
);
