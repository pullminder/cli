# Pullminder CLI

Cross-platform binaries for the [Pullminder](https://pullminder.com) CLI.

## Install

### Quick install (Linux / macOS)

```sh
curl -fsSL https://raw.githubusercontent.com/pullminder/cli/main/install.sh | sh
```

### Homebrew (macOS / Linux)

```sh
brew install pullminder/tap/pullminder
```

### npm

```sh
npx pullminder --help
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

## Usage

```sh
pullminder registry init
pullminder registry validate --strict
pullminder registry pack add --slug my-rules --kind detection --name "My Rules"
pullminder version
```

## License

MIT
