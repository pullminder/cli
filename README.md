# Pullminder CLI

The command-line interface for [Pullminder](https://pullminder.com) — AI-powered PR review with risk scores, reviewer briefs, policy enforcement, and CI integration.

Run rule packs against your diffs **offline** with zero configuration, or connect to the platform for AI-powered risk scoring and reviewer briefs. Output in SARIF, JUnit, or GitHub annotations for seamless CI integration.

## Install

### Quick install (Linux / macOS)

```sh
curl -fsSL https://raw.githubusercontent.com/pullminder/cli/main/install.sh | sh
```

### Homebrew

```sh
brew install pullminder/tap/pullminder
```

### npm

```sh
npx pullminder --help
# or install globally
npm install -g pullminder
```

### Manual download

Download the binary for your platform from the [releases page](https://github.com/pullminder/cli/releases).

| Platform | Binary |
|----------|--------|
| Linux (x86_64) | `pullminder-linux-amd64` |
| Linux (ARM64) | `pullminder-linux-arm64` |
| macOS (Intel) | `pullminder-darwin-amd64` |
| macOS (Apple Silicon) | `pullminder-darwin-arm64` |
| Windows (x86_64) | `pullminder-windows-amd64.exe` |

## Quick start

### Analyze your current branch (offline, no account needed)

```sh
pullminder check
```

### Run in CI with GitHub annotations

```sh
pullminder ci --github-annotations --fail-on high
```

### Analyze a remote PR

```sh
pullminder diff https://github.com/owner/repo/pull/123
pullminder score owner/repo#123
pullminder brief owner/repo#123
```

### Initialize a project config

```sh
pullminder init --yes
```

## Global flags

| Flag | Description |
|------|-------------|
| `--agent` | Agent-optimized JSON output for AI coding agents (Copilot, Claude Code, Cursor, etc.) |

The `--agent` flag is available on **all commands** and produces structured JSON suitable for machine consumption.

## Commands

### Local analysis

These commands work offline against your local git repository. No authentication required.

#### `pullminder init`

Create a `.pullminder.yml` project configuration file.

```sh
pullminder init          # Interactive setup
pullminder init --yes    # Non-interactive with defaults
```

#### `pullminder check`

Run rule packs against the current branch diff. Works offline with built-in rule packs.

```sh
pullminder check
pullminder check --base develop
pullminder check --diff changes.patch
pullminder check --files "src/**/*.ts"
pullminder check --strict --sarif > results.sarif
```

| Flag | Description |
|------|-------------|
| `--base <branch>` | Base branch to diff against (default: auto-detect main/master) |
| `--diff <file>` | Path to a diff file (skips git diff) |
| `--files <glob>` | Check specific files only |
| `--strict` | Exit code 1 on any warning |
| `--json` | JSON output |
| `--sarif` | SARIF v2.1.0 output |

#### `pullminder ci`

Run diff-aware analysis optimized for CI pipelines. Auto-detects GitHub Actions, GitLab CI, CircleCI, Jenkins, and Bitbucket Pipelines.

```sh
pullminder ci
pullminder ci --strict --sarif > results.sarif
pullminder ci --junit > results.xml
pullminder ci --github-annotations --fail-on critical
```

| Flag | Description |
|------|-------------|
| `--base <branch>` | Base branch (default: auto-detect from CI environment) |
| `--strict` | Exit code 1 on any finding (default in CI) |
| `--json` | JSON output |
| `--sarif` | SARIF v2.1.0 output for GitHub Code Scanning |
| `--junit` | JUnit XML output for CI test reporters |
| `--github-annotations` | Output `::warning`/`::error` workflow commands |
| `--fail-on <severity>` | Minimum severity to cause failure: `low`, `medium`, `high`, `critical` |

### Platform commands

These commands require a GitHub token via `GITHUB_TOKEN`, `GH_TOKEN`, or the GitHub CLI (`gh`).

#### `pullminder diff <pr-url>`

Run rule packs against a remote GitHub PR. Read-only — never modifies the PR.

```sh
pullminder diff https://github.com/owner/repo/pull/123
pullminder diff owner/repo#123
pullminder diff owner/repo#123 --pack secrets --strict
```

| Flag | Description |
|------|-------------|
| `--pack <slug>` | Run a specific pack only |
| `--strict` | Exit code 1 on any finding |
| `--json` | JSON output |
| `--sarif` | SARIF v2.1.0 output |

#### `pullminder score <pr-url>`

Fetch the Pullminder risk score and breakdown for a PR.

```sh
pullminder score owner/repo#123
pullminder score owner/repo#123 --json
```

#### `pullminder brief <pr-url>`

Fetch the AI-generated reviewer brief for a PR.

```sh
pullminder brief owner/repo#123
pullminder brief owner/repo#123 --markdown | pbcopy
```

| Flag | Description |
|------|-------------|
| `--json` | JSON output |
| `--markdown` | Raw markdown output (for piping) |

### Authentication

#### `pullminder auth`

Manage authentication with the Pullminder platform.

```sh
pullminder auth login --token <key>
pullminder auth logout
pullminder auth status
pullminder auth switch-org --org my-team
```

| Subcommand | Description | Flags |
|------------|-------------|-------|
| `login` | Authenticate with the platform | `--token <key>`, `--api-host <url>` |
| `logout` | Remove stored credentials | |
| `status` | Show current authentication state | |
| `switch-org` | Switch active organization | `--org <slug>` (required) |

### Configuration

#### `pullminder config`

View and manage `.pullminder.yml` configuration.

```sh
pullminder config show
pullminder config show --org --json
pullminder config set min_severity high
pullminder config export > backup.yml
pullminder config import backup.yml
pullminder config diff
```

| Subcommand | Description | Flags |
|------------|-------------|-------|
| `show` | Show current config | `--org`, `--json` |
| `set <key> <value>` | Set a config value | |
| `export` | Export as YAML to stdout | |
| `import <file>` | Import from YAML file | |
| `diff` | Compare local vs platform configuration | `--json` |

### Rule packs

#### `pullminder packs`

Browse and manage rule packs.

```sh
pullminder packs list
pullminder packs list --enabled --json
pullminder packs info secrets
pullminder packs enable go-security
pullminder packs disable bot-detection
```

| Subcommand | Description | Flags |
|------------|-------------|-------|
| `list` | List all available rule packs | `--enabled`, `--json` |
| `info <slug>` | Show details about a pack | `--json` |
| `enable <slug>` | Enable a rule pack | |
| `disable <slug>` | Disable a rule pack | |

#### `pullminder rules`

Develop, test, and publish rule packs.

```sh
pullminder rules test
pullminder rules test --pack my-pack --verbose
pullminder rules publish --dry-run
pullminder rules publish --pack my-pack
```

| Subcommand | Description | Flags |
|------------|-------------|-------|
| `test [dir]` | Run packs against fixture diffs | `--pack`, `--verbose`, `--json` |
| `publish [dir]` | Publish a pack to community registry | `--pack`, `--dry-run`, `--github-token`, `--title`, `--branch` |

### Git hooks

#### `pullminder hooks`

Manage git hook integration for automatic pre-push or pre-commit analysis. Detects existing hook managers (Husky, Lefthook, pre-commit).

```sh
pullminder hooks install
pullminder hooks install --hook pre-commit --force
pullminder hooks uninstall
pullminder hooks status
```

| Subcommand | Description | Flags |
|------------|-------------|-------|
| `install` | Install a git hook | `--hook pre-push\|pre-commit`, `--force` |
| `uninstall` | Remove pullminder git hooks | |
| `status` | Show installed pullminder hooks | |

### Custom registries

#### `pullminder registry`

Create and manage custom rule registries.

```sh
pullminder registry init my-company-rules
pullminder registry validate --strict
pullminder registry upgrade
pullminder registry pack add --slug our-checks --kind detection --name "Our Checks"
pullminder registry pack list
pullminder registry pack remove --slug old-pack
```

| Subcommand | Description | Flags |
|------------|-------------|-------|
| `init <name>` | Scaffold a new registry | |
| `validate` | Validate registry structure | `--strict` |
| `upgrade` | Upgrade registry schema | |
| `pack add` | Add a pack to registry | |
| `pack list` | List packs in registry | |
| `pack remove` | Remove a pack from registry | |

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success, no findings (or findings below threshold) |
| `1` | Findings detected (with `--strict` or `--fail-on`), or critical/error severity |
| `2` | Warnings detected (without `--strict`) |

## CI integration examples

### GitHub Actions

```yaml
- name: Pullminder analysis
  run: npx pullminder ci --github-annotations --fail-on high
```

### GitHub Actions with SARIF upload

```yaml
- name: Run Pullminder
  run: npx pullminder ci --sarif > pullminder.sarif
- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: pullminder.sarif
```

### GitLab CI

```yaml
pullminder:
  script:
    - npx pullminder ci --junit > pullminder-report.xml
  artifacts:
    reports:
      junit: pullminder-report.xml
```

### GitHub Action for registry validation

```yaml
- uses: pullminder/action@v1
```

## Links

- [Pullminder](https://pullminder.com) — AI-powered PR review platform
- [Documentation](https://pullminder.com/docs)
- [Registry](https://github.com/pullminder/registry) — Official rule pack registry
- [GitHub Action](https://github.com/pullminder/action) — CI validation action
- [npm](https://github.com/pullminder/npm) — npm wrapper
- [Homebrew Tap](https://github.com/pullminder/homebrew-tap) — macOS/Linux install

## License

Apache-2.0
