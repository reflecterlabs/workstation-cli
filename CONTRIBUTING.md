# Contributing to Workstation CLI

First off, thank you for considering contributing to Workstation CLI! It's people like you that make this tool better for everyone.

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [existing issues](https://github.com/reflecterlabs/workstation-cli/issues) to see if the problem has already been reported.

When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed and what behavior you expected**
- **Include code snippets and terminal output**

### Suggesting Enhancements

Enhancement suggestions are tracked as [GitHub issues](https://github.com/reflecterlabs/workstation-cli/issues).

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the enhancement**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 🚀 Development Setup

### Prerequisites

- bash 4.0+
- jq
- git
- shellcheck (for linting)
- bats (for testing)

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt-get install jq git shellcheck bats

# Install dependencies (macOS)
brew install jq git shellcheck bats-core
```

### Setup

```bash
# Clone your fork
git clone https://github.com/your-username/workstation-cli.git
cd workstation-cli

# Run tests
make test

# Run linter
make lint
```

### Project Structure

```
workstation-cli/
├── bin/
│   └── workstation          # Main CLI script
├── lib/                     # Library functions
├── templates/               # Seat templates
├── docs/                    # Documentation
├── tests/                   # Test suite
└── examples/                # Example configurations
```

## 📝 Style Guidelines

### Shell Script Style

We follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) with some modifications:

- Use `#!/usr/bin/env bash`
- Use `set -euo pipefail`
- Quote all variables: `"${var}"`
- Use lowercase for local variables
- Use UPPERCASE for constants and exported variables
- Functions should be `snake_case`

### Example

```bash
#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

my_function() {
  local arg1="$1"
  local arg2="$2"
  
  if [[ -f "$arg1" ]]; then
    echo "File exists: $arg1"
  fi
}
```

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

Examples:
```
Add seat sync command with snapshot support

- Creates timestamped snapshots
- Maintains 30 snapshot retention
- Updates workstation.json with sync time

Fixes #123
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
make test

# Run specific test
./tests/run-tests.sh

# Run with debug output
WORKSTATION_DEBUG=1 make test
```

### Writing Tests

Tests use [Bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System):

```bash
#!/usr/bin/env bats

@test "version command returns correct format" {
  run workstation version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Workstation CLI" ]]
}

@test "init creates organization directory" {
  run workstation init "TestOrg$$"
  [ "$status" -eq 0 ]
  [ -d "$WORKSTATION_ROOT/TestOrg$$-SSOT" ]
}
```

## 📚 Documentation

- Update the README.md if you change functionality
- Update docs/ if you add new features
- Add examples to examples/ for complex features

## 🏷️ Release Process

1. Update version in `bin/workstation`
2. Update CHANGELOG.md
3. Create git tag: `git tag -a v2.1.0 -m "Release version 2.1.0"`
4. Push tag: `git push origin v2.1.0`
5. GitHub Actions will create the release

## 💬 Community

- [Discord](https://discord.gg/reflecterlabs)
- [Twitter](https://twitter.com/reflecterlabs)
- [Discussions](https://github.com/reflecterlabs/workstation-cli/discussions)

## 🙏 Recognition

Contributors will be:
- Listed in the README
- Mentioned in release notes
- Added to the contributors graph

---

Thank you for contributing! 🎉
