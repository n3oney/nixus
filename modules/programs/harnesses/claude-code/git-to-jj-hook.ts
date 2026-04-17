#!/usr/bin/env bun
// PreToolUse hook: steer git usage toward jujutsu (jj).
//
// Reads the Claude Code hook payload on stdin. When the Bash command is a git
// invocation it either transparently redirects a safe read-only command to its
// jj equivalent (via updatedInput) or denies the call with a jj hint. Anything
// that isn't git prints nothing and exits 0, so the command runs untouched.

interface Payload {
  tool_input?: { command?: string; [key: string]: unknown };
}

// git subcommand -> jj subcommand, for commands safe to run transparently.
const REDIRECT: Record<string, string> = {
  status: "st",
  st: "st",
  log: "log",
  diff: "diff",
  show: "show",
};

// git subcommand -> what to do in jj instead, for everything we won't run.
const DENY_HINTS: Record<string, string> = {
  add: "jj snapshots edits to tracked files automatically. For new files use `jj file track <paths>` (needed before e.g. nix sees them).",
  commit: "Use `jj commit -m '…'` (finalize working copy) or `jj describe -m '…'` (set message).",
  push: "Use `jj git push`.",
  fetch: "Use `jj git fetch`.",
  pull: "Use `jj git fetch` then `jj rebase`/`jj new`.",
  clone: "Use `jj git clone`.",
  init: "Use `jj git init`.",
  branch: "Use `jj bookmark list` / `jj bookmark set <name>`.",
  checkout: "Use `jj new <rev>` (new change) or `jj edit <rev>` (edit existing).",
  switch: "Use `jj new <rev>` (new change) or `jj edit <rev>` (edit existing).",
  restore: "Use `jj restore [paths]`.",
  reset: "Use `jj restore`, `jj abandon`, or `jj op restore` depending on intent.",
  rebase: "Use `jj rebase -d <dest>`.",
  merge: "Use `jj new <rev1> <rev2>` to create a merge change.",
  stash: "No stash needed — your working copy is already a change. Use `jj new` to set it aside.",
  mv: "Just use plain `mv`; jj tracks the rename automatically.",
  rm: "Just use plain `rm`; jj tracks the deletion automatically.",
};
const DEFAULT_HINT = "Find the jj equivalent — see `jj help`.";

// A standalone git command token anywhere in the (possibly compound) command.
const GIT_TOKEN = /(^|[;&|(])\s*git(\s|$)/;

function emit(decision: "allow" | "deny", reason: string, updatedInput?: unknown): never {
  const hookSpecificOutput: Record<string, unknown> = {
    hookEventName: "PreToolUse",
    permissionDecision: decision,
    permissionDecisionReason: reason,
  };
  if (updatedInput !== undefined) hookSpecificOutput.updatedInput = updatedInput;

  const out: Record<string, unknown> = { hookSpecificOutput };
  if (decision === "allow") out.systemMessage = reason; // surface the redirect to the user too

  console.log(JSON.stringify(out, null, 2));
  process.exit(0);
}

const payload: Payload = JSON.parse(await Bun.stdin.text());
const cmd = payload.tool_input?.command ?? "";
const trimmed = cmd.replace(/^\s+/, "");

// Simple `git ...` command (no shell operators before it): try to redirect.
if (/^git(\s|$)/.test(trimmed)) {
  const parts = trimmed.split(/\s+/);
  const sub = parts[1] ?? "";
  const args = parts.slice(2).join(" ");

  const jjsub = REDIRECT[sub];
  if (jjsub) {
    const newcmd = `jj ${jjsub}${args ? ` ${args}` : ""}`;
    emit(
      "allow",
      `git is disabled in this jj repo — redirected \`${trimmed}\` to \`${newcmd}\`. Use jj directly next time.`,
      { ...payload.tool_input, command: newcmd },
    );
  }

  const hint = DENY_HINTS[sub] ?? DEFAULT_HINT;
  emit("deny", `git is disabled in this jj repo (\`${trimmed}\`). ${hint}`);
}

// git buried in a compound command (e.g. `cd x && git commit`): block without
// rewriting, since rewriting a compound command safely is unreliable.
if (GIT_TOKEN.test(cmd)) {
  emit(
    "deny",
    "This repo uses jujutsu (jj); raw git is disabled. Run the jj equivalent as its own command — see `jj help`.",
  );
}

process.exit(0);
