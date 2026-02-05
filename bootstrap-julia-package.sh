#!/usr/bin/env bash

set -e

echo "Julia Package Bootstrapper"
echo "=========================="
echo "This script will create a new Julia package with standard structure."
echo

# Default values
DEFAULT_PACKAGE_NAME="MyPackage"
DEFAULT_AUTHOR_NAME="$(git config user.name 2>/dev/null || echo '')"
DEFAULT_AUTHOR_EMAIL="$(git config user.email 2>/dev/null || echo '')"
DEFAULT_YEAR="$(date +%Y)"
DEFAULT_JULIA_VERSION="1.12"

# Wizard prompts
read -p "Package name [${DEFAULT_PACKAGE_NAME}]: " PACKAGE_NAME
PACKAGE_NAME=${PACKAGE_NAME:-$DEFAULT_PACKAGE_NAME}

read -p "Author name [${DEFAULT_AUTHOR_NAME}]: " AUTHOR_NAME
AUTHOR_NAME=${AUTHOR_NAME:-$DEFAULT_AUTHOR_NAME}

read -p "Author email [${DEFAULT_AUTHOR_EMAIL}]: " AUTHOR_EMAIL
AUTHOR_EMAIL=${AUTHOR_EMAIL:-$DEFAULT_AUTHOR_EMAIL}

read -p "Julia version [${DEFAULT_JULIA_VERSION}]: " JULIA_VERSION
JULIA_VERSION=${JULIA_VERSION:-$DEFAULT_JULIA_VERSION}

read -p "Short description (optional): " DESCRIPTION

echo
echo "Generating package: $PACKAGE_NAME"
echo "Author: $AUTHOR_NAME <$AUTHOR_EMAIL>"
echo "Julia version: $JULIA_VERSION"
echo

# Validate package name (Julia packages should be valid identifiers)
if [[ ! "$PACKAGE_NAME" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
    echo "Error: Package name must be a valid Julia identifier (start with letter, only alphanumeric)."
    exit 1
fi

# Create directory structure
mkdir -p src
mkdir -p test
mkdir -p docs
mkdir -p .github/workflows

echo "Creating files..."

# Create README.md
cat > README.md <<EOF
# $PACKAGE_NAME

$( [ -n "$DESCRIPTION" ] && echo "$DESCRIPTION" || echo "A Julia package." )

## Installation

\`\`\`julia
import Pkg
Pkg.add("$PACKAGE_NAME")
\`\`\`

## Usage

\`\`\`julia
using $PACKAGE_NAME
\`\`\`

## Development

### Running tests

\`\`\`bash
make test
\`\`\`

### Running linter

\`\`\`bash
make lint
\`\`\`

### Building documentation

\`\`\`bash
make docs
\`\`\`

## License

MIT License. See LICENSE file for details.
EOF

# Create AGENTS.md
cat > AGENTS.md <<EOF
# AGENTS.md

This document contains conventions and instructions for AI agents (like opencode) working with this repository.

## Code Style

- Follow Julia style guide: https://docs.julialang.org/en/v1/manual/style-guide/
- Use 4 spaces for indentation
- Use descriptive variable names
- Write docstrings for exported functions

## Testing

- All exported functions must have tests
- Tests are in the \`test/\` directory
- Run tests with \`make test\` or \`julia --project test/runtests.jl\`

## Linting and Formatting

- Use \`make lint\` to run JuliaFormatter and other linters
- Use \`make format\` to auto-format code
- Ensure no linting errors before committing

## Documentation

- Documentation is built with Documenter.jl
- Run \`make docs\` to generate and serve documentation locally
- Documentation source is in \`docs/\` directory

## Commit Messages

- Use conventional commits: feat, fix, docs, style, refactor, test, chore
- Keep commits focused and atomic
- Reference issue numbers when applicable

## Pull Requests

- Ensure all tests pass
- Update documentation as needed
- Keep PRs small and focused
EOF

# Create MIT LICENSE
cat > LICENSE <<EOF
MIT License

Copyright (c) $DEFAULT_YEAR $AUTHOR_NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Create Makefile
cat > Makefile <<EOF
.PHONY: help test lint format docs clean install dev

help:
	@echo "Available targets:"
	@echo "  install    - Install dependencies"
	@echo "  dev        - Start development environment"
	@echo "  test       - Run tests"
	@echo "  lint       - Run linters"
	@echo "  format     - Auto-format code"
	@echo "  docs       - Generate and serve documentation"
	@echo "  clean      - Clean build artifacts"

install:
	julia --project -e 'import Pkg; Pkg.instantiate()'

dev: install
	@echo "Development environment ready. Use 'julia --project' to start."

test:
	julia --project test/runtests.jl

lint:
	julia --project -e 'using JuliaFormatter; format(".", verbose=true)'
	@echo "Linting complete."

format:
	julia --project -e 'using JuliaFormatter; format(".", verbose=true)'

docs:
	julia --project docs/make.jl

clean:
	rm -rf docs/build
	rm -rf Manifest.toml
EOF

# Create Project.toml
cat > Project.toml <<EOF
name = "$PACKAGE_NAME"
uuid = "$(uuidgen | tr '[:upper:]' '[:lower:]')"
authors = ["$AUTHOR_NAME <$AUTHOR_EMAIL>"]
version = "0.1.0"

[compat]
julia = "$JULIA_VERSION"

[deps]
Documenter = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
JuliaFormatter = "98e50ef6-434e-11e9-1051-2b60c6c9e899"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[extras]
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[targets]
test = ["Test"]
EOF

# Create src/PACKAGE_NAME.jl
cat > src/${PACKAGE_NAME}.jl <<EOF
module $PACKAGE_NAME

export hello, fib

"""
    hello()

Return the string "Hello, World!".
"""
hello() = "Hello, World!"

"""
    fib(n::Integer)

Compute the nth Fibonacci number.
"""
function fib(n::Integer)
    n <= 1 && return n
    a, b = 0, 1
    for _ in 2:n
        a, b = b, a + b
    end
    return b
end

end # module
EOF

# Create test/runtests.jl
cat > test/runtests.jl <<EOF
using $PACKAGE_NAME
using Test

@testset "$PACKAGE_NAME.jl" begin
    @test hello() == "Hello, World!"
    
    @test fib(0) == 0
    @test fib(1) == 1
    @test fib(2) == 1
    @test fib(3) == 2
    @test fib(10) == 55
    
    @test_throws MethodError fib("not a number")
end
EOF

# Create docs/make.jl
mkdir -p docs/src
cat > docs/make.jl <<EOF
using Documenter
using $PACKAGE_NAME

makedocs(
    sitename = "$PACKAGE_NAME",
    format = Documenter.HTML(),
    modules = [$PACKAGE_NAME],
    pages = [
        "Home" => "index.md",
        "API Reference" => "api.md",
    ]
)

deploydocs(
    repo = "github.com/username/$PACKAGE_NAME.jl.git",
)
EOF

# Create docs/src/index.md
cat > docs/src/index.md <<EOF
# $PACKAGE_NAME Documentation

$( [ -n "$DESCRIPTION" ] && echo "$DESCRIPTION" || echo "A Julia package." )

## Getting Started

\`\`\`julia
import Pkg
Pkg.add("$PACKAGE_NAME")
using $PACKAGE_NAME
\`\`\`

## Examples

\`\`\`julia
hello()  # returns "Hello, World!"
fib(10)  # returns 55
\`\`\`
EOF

# Create docs/src/api.md
cat > docs/src/api.md <<EOF
# API Reference

\`\`\`@docs
hello
fib
\`\`\`
EOF

# Create .gitignore
cat > .gitignore <<EOF
*.jl.cov
*.jl.*.cov
*.jl.mem
.DS_Store
Manifest.toml
docs/build/
*.local
*.orig
*.pyc
__pycache__/
.env
*.log
*.swp
*.bak
*.tmp
*.tar.gz
*.zip
*.so
*.dylib
*.dll
*.exe
*.out
*.pdf
*.aux
*.log
*.toc
*.blg
*.bbl
*.synctex.gz
*.fls
*.fdb_latexmk
*.idx
*.ilg
*.ind
*.bcf
*.run.xml
*.vrb
*.snm
*.nav
*.thm
*.loe
*.lof
*.lot
*.out.ps
*.dvi
*.ps
.vscode/
.idea/
*.iml
*.ipr
*.iws
*.sublime-*
*.code-workspace
*.ropeproject
.history
node_modules/
dist/
build/
.coverage
htmlcov/
.pytest_cache/
.mypy_cache/
.tox/
.coverage.*
*.egg-info/
*.egg
.Python
pip-log.txt
pip-delete-this-directory.txt
__pycache__
*.py[cod]
*$py.class
*.so
.Python
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
*.sqlite3
*.db
instance/
.ipynb_checkpoints
*.ipynb
.nbdime
*.sage.py
# Julia files
*.jl.cov
*.jl.*.cov
*.jl.mem
*.jl~*
# Documenter.jl
docs/build/
docs/site/
# test coverage
coverage/
# IDE
.julia_history
.julia_environments/
EOF

# Create .github/workflows/ci.yml
cat > .github/workflows/ci.yml <<EOF
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        julia-version: ['1.9', '1.10', '1.11']

    steps:
      - uses: actions/checkout@v4
      - uses: julia-actions/setup-julia@v1
        with:
          version: \${{ matrix.julia-version }}
      - name: Install dependencies
        run: |
          julia --project -e 'import Pkg; Pkg.instantiate()'
      - name: Run tests
        run: |
          julia --project test/runtests.jl
      - name: Run lint
        run: |
          julia --project -e 'using JuliaFormatter; format(".", verbose=true)'
      - name: Build documentation
        run: |
          julia --project docs/make.jl

  docs:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: julia-actions/setup-julia@v1
        with:
          version: '1.9'
      - name: Install dependencies
        run: |
          julia --project -e 'import Pkg; Pkg.instantiate()'
      - name: Build and deploy documentation
        run: |
          julia --project docs/make.jl
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
EOF

# Create Jenkinsfile
cat > Jenkinsfile <<EOF
pipeline {
    agent any
    
    tools {
        julia 'julia-latest'
    }
    
    environment {
        JULIA_PROJECT = '.'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'julia --project -e "import Pkg; Pkg.instantiate()"'
            }
        }
        
        stage('Lint') {
            steps {
                sh 'julia --project -e "using JuliaFormatter; format(\".\", verbose=true)"'
            }
        }
        
        stage('Test') {
            steps {
                sh 'julia --project test/runtests.jl'
            }
        }
        
        stage('Build Docs') {
            steps {
                sh 'julia --project docs/make.jl'
            }
        }
        
        stage('Package') {
            steps {
                sh '''
                    tar -czf ${PACKAGE_NAME}.tar.gz src test docs README.md LICENSE Project.toml
                '''
                archiveArtifacts artifacts: '${PACKAGE_NAME}.tar.gz'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
EOF

echo "Package $PACKAGE_NAME created successfully!"
echo
echo "Next steps:"
echo "1. Review the generated files"
echo "2. Run 'make install' to install dependencies"
echo "3. Run 'make test' to run tests"
echo "4. Run 'make docs' to build documentation"
echo "5. Initialize git repository: git init && git add . && git commit -m 'Initial commit'"
echo
echo "Happy coding!"
