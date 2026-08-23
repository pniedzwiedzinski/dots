# AGENTS.md

## Scope and Repository

These instructions apply to the entire repository. No more-specific `AGENTS.md`,
Cursor rules, or Copilot instructions currently exist. If one is added, follow
the most specific applicable instructions.

This is a personal NixOS homelab/workstation flake named `dots`. It uses Snowfall
Lib, Home Manager, deploy-rs, disko, and impermanence. Nix is the primary language,
with small Bash, Python, YAML, and JSON components.

Root-flake hosts are `t14` (laptop), `srv2` (Raspberry Pi GPIO gateway), `srv3`
(primary services), `srv5` (NVIDIA/Ollama), and `backup` (ZFS/Borg target).

Key paths:

- `flake.nix`: inputs, Snowfall configuration, deploy nodes, and checks.
- `systems/<architecture>/<host>/`: host-specific NixOS configuration (imports
  `hardware-configuration.nix` from `default.nix`; `configuration.nix` holds
  host-specific overrides and enables service modules).
- `modules/nixos/<name>/default.nix`: reusable NixOS modules auto-discovered by
  Snowfall Lib (each declares `dots.<name>.*` options gated by `enable`).
- `packages/`: custom shell applications and Nix wrappers.
- `lib/default.nix`: shared flake/deploy helpers.
- `shells/default/default.nix`: development shell.
- `.github/workflows/`: CI and dependency updates.

## Development, Build, and Validation

Enter the development shell when deploy-rs or repository tooling is needed:

```bash
nix develop
```

Run root-flake commands from the repository root. Run all declared checks with:

```bash
nix flake check
```

Build one host through the deploy attribute used by CI:

```bash
nix build .#deploy.nodes.<host>.profiles.system.path
nix build .#deploy.nodes.srv3.profiles.system.path
```

A direct NixOS build is also available:

```bash
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
```

Inspect available outputs/check names when uncertain:

```bash
nix flake show
```

## Tests and Single-Test Guidance

There is no unit/integration suite, NixOS VM test, test runner, or named-test
command. Treat `nix flake check` as full validation. The closest equivalent to a
single test is a targeted host build, for example:

```bash
nix build .#deploy.nodes.srv5.profiles.system.path
```

For host-specific changes, build every affected host. For shared modules or
libraries, run `nix flake check` and build representative affected architectures
when practical. Do not claim tests passed when only evaluation/build was done.

## Formatting and Linting

There is no root formatter output, treefmt/pre-commit configuration, or configured
repository-wide linter. `nix fmt` is not supported. Format only changed Nix files
with `nixfmt-rfc-style` (binary `nixfmt`):

```bash
nixfmt path/to/changed-file.nix
nix run nixpkgs#nixfmt-rfc-style -- path/to/changed-file.nix
```

The second form works when `nixfmt` is not installed. Shell scripts contain
ShellCheck directives, but no ShellCheck CI command exists. If available, run
ShellCheck on changed scripts without adding broad suppressions. No Python
formatter, type checker, or linter is configured; preserve local style.

## Nix Style

- Follow `nixfmt-rfc-style`; use two-space indentation and trailing semicolons.
- Put multiline function arguments one per line and retain `...` where needed.
- Group relative paths in an `imports = [ ... ];` list near the module top.
- Prefer relative imports for repository-local modules.
- Keep related option trees together rather than scattering assignments.
- Use `let ... in` for local helpers/repeated values and `inherit` when forwarding.
- Prefer library functions and attribute transformations over duplication.
- In reusable modules, bind `cfg = config.<namespace>`.
- Gate optional configuration with `lib.mkIf cfg.enable`.
- Define booleans with `lib.mkEnableOption` where appropriate.
- Other options use `lib.mkOption` with an explicit `type`, sensible `default`,
  and useful `description`.
- Use `lib.mkDefault` for caller-overridable defaults.
- Keep list/attribute ordering stable unless order has semantic value.
- Avoid unnecessary `with`; explicit `pkgs.foo` and `lib.foo` are clearer.
- Do not add unpinned external sources outside the flake input pattern.

## Naming, Imports, and Types

- Nix locals, arguments, options, and helpers use camelCase.
- Nix modules/files and package directories use lowercase kebab-case.
- Hosts use lowercase names such as `srv3`, `t14`, and `backup`.
- Python functions/variables use snake_case; constants use UPPER_SNAKE_CASE.
- Shell environment variables and constants use UPPER_SNAKE_CASE.
- Python imports stay at the top, grouped as standard, third-party, then local.
- Use explicit Nix option types such as `lib.types.bool`, `str`, and `int`.
- Preserve option schemas; do not change types without considering migration impact.
- Never change `system.stateVersion` without an intentional migration.

## Bash and Python Style

- Use Bash syntax only with a Bash shebang.
- Quote shell expansions and paths (`"$value"`); use `[[ ... ]]` and arrays.
- Validate required inputs, report failures, and return nonzero on errors.
- Add command dependencies to the surrounding `writeShellApplication`.
- Avoid `eval`; do not expand the scope of existing uses.
- Never print API keys, tokens, credentials, or secret file contents.
- Python uses four-space indentation and f-strings.
- Use the existing logger rather than `print` for service diagnostics.
- Catch the narrowest useful exception and log actionable context.
- Translate expected failures into explicit status responses or booleans.
- Preserve `finally` cleanup for GPIO and other external resources.
- Update Nix packaging when adding Python or shell runtime dependencies.

## Error Handling and Safety

- Prefer evaluation/build failures over silently ignored invalid configuration.
- Make service failure states explicit and provide useful, non-secret diagnostics.
- Never expose secrets in errors, logs, generated files, or commits.
- Do not deploy, switch a system, write an SD card, or run `sudo` unless explicitly
  requested. The `rebuild` helper switches the system and may create a commit.
- Do not commit or push unless explicitly requested.

## Generated and Sensitive Files

- Never manually edit generated `hardware-configuration.nix` files.
- `systems/x86_64-linux/srv5/docker-compose.nix` is generated by compose2nix;
  modify `docker-compose.yml` and regenerate it instead.
- Update `flake.lock` files with Nix tooling, never by hand.
- Never decrypt, print, or modify tracked `.age` secrets unless explicitly asked.
- Treat credential paths, SSH keys, API tokens, and host secrets as sensitive.
- Avoid artifacts such as `result`, images, logs, swap files, and backups.

## Agent Workflow

1. Read the affected host/module and neighboring files before editing.
2. Identify all hosts and architectures affected by shared changes.
3. Make the smallest change that follows existing patterns.
4. Format each changed Nix file.
5. Run the narrowest useful host build, then `nix flake check` when practical.
6. Report exact validation commands and any failures or omissions.
