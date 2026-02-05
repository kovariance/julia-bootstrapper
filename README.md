# Julia Package Bootstrapper

A shell script to quickly bootstrap new Julia packages with a complete, production-ready project structure.

## Features

- Interactive wizard for package configuration
- Standard Julia package directory structure
- Pre-configured testing with Test.jl
- Documentation setup with Documenter.jl
- Code formatting with JuliaFormatter
- Makefile with common development tasks
- GitHub Actions CI/CD pipeline
- Jenkins pipeline configuration
- MIT License template
- Comprehensive .gitignore
- Example code and tests to get started

## Requirements

- Bash
- Git
- Julia (recommended: 1.9 or later)
- `uuidgen` (usually pre-installed on Unix systems)

## Usage

```bash
./bootstrap-julia-package.sh
```

The script will prompt you for:
- Package name (must be a valid Julia identifier)
- Author name (defaults to git config user.name)
- Author email (defaults to git config user.email)
- Julia version (defaults to 1.12)
- Short description (optional)

## Generated Structure

```
MyPackage/
├── src/
│   └── MyPackage.jl       # Main module file
├── test/
│   └── runtests.jl        # Test suite
├── docs/
│   ├── make.jl            # Documentation builder
│   └── src/
│       ├── index.md       # Documentation home
│       └── api.md         # API reference
├── .github/
│   └── workflows/
│       └── ci.yml         # GitHub Actions CI
├── Project.toml           # Package metadata
├── Makefile               # Development tasks
├── README.md              # Package README
├── AGENTS.md              # AI agent conventions
├── LICENSE                # MIT License
├── Jenkinsfile            # Jenkins pipeline
└── .gitignore             # Git ignore rules
```

## Development Tasks

After generating a package, the following Makefile targets are available:

- `make install` - Install package dependencies
- `make test` - Run test suite
- `make lint` - Run code linter/formatter
- `make format` - Auto-format code
- `make docs` - Generate and serve documentation
- `make clean` - Clean build artifacts

## Example

```bash
$ ./bootstrap-julia-package.sh
Julia Package Bootstrapper
==========================
This script will create a new Julia package with standard structure.

Package name [MyPackage]: AwesomePackage
Author name [John Doe]:
Author email [john@example.com]:
Julia version [1.12]:
Short description (optional): An awesome Julia package for doing awesome things

Generating package: AwesomePackage
Author: John Doe <john@example.com>
Julia version: 1.12

Creating files...
Package AwesomePackage created successfully!
```

## License

MIT License. See LICENSE file for details.
