# AGENTS.md

Raycast [Script Commands](https://github.com/raycast/script-commands) — small executable scripts that Raycast surfaces as commands. Each script is a standalone file (`.sh`, `.applescript`, etc.) with a shebang, an executable bit (`chmod +x`), and a metadata header of `@raycast.*` comments.

## What lives here

Scripts live in `scripts/`, one file per command. Current inhabitants:

- `scripts/bsky-resolve.sh` — resolve a Bluesky handle to a DID
- `scripts/fxtwitter-clipboard.sh` — rewrite an x.com/twitter.com link in the clipboard to fxtwitter.com
- `scripts/warp-connect.sh` / `scripts/warp-disconnect.sh` — toggle Cloudflare WARP
- `scripts/glide-pause.sh` / `scripts/glide-resume.sh` — pause/resume the Glide window manager
- `scripts/idasen-desk-move-to-sit.applescript` / `scripts/idasen-desk-move-to-stand.applescript` — drive an Idasen standing desk via the Desk Controller app

Point Raycast's Script Commands directory at `scripts/`.

## Anatomy of a script

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title My Command
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🚀
# @raycast.argument1 { "type": "text", "placeholder": "handle" }

echo "do the thing"
```

Rules of the road:

- First line is the shebang. `#!/bin/bash`, `#!/usr/bin/osascript`, `#!/usr/bin/env node`, whatever.
- Metadata lives in comments using either `#` or `//`, whichever suits the language. The `@raycast.*` keys are what matter.
- **Required:** `schemaVersion` (always `1`), `title`, `mode`.
- Make it executable: `chmod +x yourscript.sh`.
- A non-zero exit triggers a failure toast; in `inline`/`compact` modes the final output line is shown as the error message.

### Full metadata reference

Required:

| Key             | Meaning                              |
| --------------- | ------------------------------------ |
| `schemaVersion` | Always `1`. Future-proofing hook.    |
| `title`         | Display name in root search.         |
| `mode`          | Execution + output mode (see below). |

Optional:

| Key                     | Meaning                                                                                                                             |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `packageName`           | Subtitle in root search. Defaults to the script's directory name.                                                                   |
| `icon`                  | Emoji, relative/absolute file path, or `https` URL. PNG/JPEG, ~64px recommended.                                                    |
| `iconDark`              | Same as `icon` but for dark theme; falls back to `icon`.                                                                            |
| `currentDirectoryPath`  | Working directory the script runs from. Defaults to the script's own path.                                                          |
| `needsConfirmation`     | `true` shows a confirmation dialog before running. Defaults to `false`.                                                             |
| `refreshTime`           | Auto-refresh interval for `inline` mode (`10s`, `1m`, `12h`, `1d`). Minimum `10s`; at most 10 inline commands auto-refresh at once. |
| `argument1`…`argument3` | Custom arguments (see below).                                                                                                       |
| `author`                | Author name, for documentation.                                                                                                     |
| `authorURL`             | Social/website/email — a way to reach the author.                                                                                   |
| `description`           | Short description, for documentation.                                                                                               |

## Arguments

Up to **3** arguments, declared as `@raycast.argument1` … `@raycast.argument3`. Each value is a JSON object. Passed to the script as positional args (`$1`, `$2`, `$3`).

```
# @raycast.argument1 { "type": "text", "placeholder": "handle", "optional": true }
```

JSON fields:

| Field            | Meaning                                                                                  | Required            |
| ---------------- | ---------------------------------------------------------------------------------------- | ------------------- |
| `type`           | `"text"`, `"password"`, or `"dropdown"`                                                  | yes                 |
| `placeholder`    | helper text shown in the input field                                                     | yes                 |
| `optional`       | `true` = argument can be skipped                                                         | no                  |
| `percentEncoded` | `true` = URL-encode the value before passing it (use when it lands in a URL query param) | no                  |
| `data`           | array of `{ "title", "value" }` objects — the options                                    | yes, for `dropdown` |

Types:

- **text** — plain text input.
- **password** — masked input (asterisks), for secrets. Replaced the deprecated `secure` param as of Raycast 1.18.0.
- **dropdown** — pick from `data`; `title` is displayed, `value` is passed to the script.

Dropdown example:

```
# @raycast.argument1 { "type": "dropdown", "placeholder": "Environment", "data": [{ "title": "Production", "value": "prod" }, { "title": "Staging", "value": "staging" }] }
```

Tip: typing the command's alias then a space jumps focus straight to the first argument.

## Output modes

Set with `@raycast.mode`:

- **silent** — no view. The last line of stdout (if any) shows in an overlay HUD toast after the Raycast window closes. Good for fire-and-forget commands (see `warp-connect.sh`).
- **compact** — the last line of stdout is shown in a toast/notification. Good default for a single-line result (see `bsky-resolve.sh`).
- **fullOutput** — the entire output is rendered in a separate terminal-like view. Use for scripts that emit a lot.
- **inline** — the first line of output is shown inline on the command item and auto-refreshes every `@raycast.refreshTime`. Requires `refreshTime` (e.g. `10s`, `1m`, `1h`); without it, falls back to `compact`. Can be favorited.

Notes:

- Long-running commands that stream lots of partial output are unreliable in `compact`/`silent`/`inline` — prefer `fullOutput`, or quiet the tool down (e.g. `zip -q`).
- `fullOutput` and `inline` support ANSI color / formatting escape codes (`0x1B[…m`): reset (0), underline (4), crossed-out (9), plus 16-color, 8-bit, and 24-bit foreground/background codes. Unsupported codes are stripped.

## Conventions in this repo

- Group metadata under `# Required parameters:` and `# Optional parameters:` comment banners, matching the existing scripts.
- Keep an emoji `@raycast.icon`.
- Bash scripts: validate arg count, check for required binaries (`curl`, `jq`, …) and fail with a clear `echo` + non-zero exit, as `bsky-resolve.sh` does.
- A file with `.template.` in its name is a template: it needs values filled in before it'll work. Handy for scripts carrying secrets/config you don't want to commit.
- Scripts run in a non-login shell; `/usr/local/bin` is appended to `$PATH`. Don't assume your interactive shell's environment is present — reference binaries by resolvable name or full path.
