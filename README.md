# Elixir (Phoenix) Nix Example

> Example repo to show off how I use Nix as build environment for Elixir / Phoenix projects.  
> Important Nix stuff is located within `default.nix` & `pkg/` folder.

> ALERT! Currently this is a lot of work in progress!

## Setup

This repo provides a quick & easy setup by the usage of [Nix](https://nixos.org).  
Nix currently runs on **Linux** and **macOS**.

- [Getting Nix](https://nixos.org/download.html)

By using Nix, beside Nix nothing else needs to be installed manually.

**Windows**  
Recommended to run the setup, also using Nix, within a Linux Virtual Machine or using WSL 2.

### Manual Setup

For maintaining simplicity, instructions for a manual setup isn't part of the documentation.  
Anyway, required dependencies:

- [Elixir](https://elixir-lang.org) (& [Erlang](https://www.erlang.org))
- [PostgreSQL](https://www.postgresql.org)
- [Node.js](https://nodejs.org)

## Development

> For convenience an [alias configuration](#aliases) exists for most of the following shell commands.

### Basics

```sh
# Get mix deps
mix deps.get

# Start Phoenix server
mix phx.server

# Start application
mix run --no-halt

# Enter IEx
iex -S mix

# JS
npm install --prefix assets
```

### Environment

```sh
# Enter shell w/ plain development environment
# Alias: `app-env`
nix-shell --pure -A env_plain

# Run basic commands without shell
nix-shell --pure -A env_plain --run '<command>'

# Enter shell w/ full development environment (inkl. Database)
nix-shell --pure -A env_full
```

### Test

```sh
# Running all tests
# Alias: `app-test`
# nix-shell --pure -A dev.env_full --argstr environment test --run 'mix test'
```

### Docs

```sh
# Generate docs using `mix docs`
# nix-build -A docs
```

### Build
```sh
# Get mix deps
nix-build -A mix_deps --option sandbox relaxed

# Compile
nix-build -A mix_build --option sandbox relaxed

# Compile cacheable -> .nix/_build
nix-shell --pure -A env_plain --command 'mix compile'

# Get JS deps
nix-build -A node_modules --option sandbox relaxed
```

### Release

```sh
# Build procution release using `mix release`
nix-build -A release --argstr environment prod --argstr release_name seed
```

### Maintenance

```sh
# Update pinned Nix pkgs
elixir pkg/scripts/pkgs_update.exs

# Check outdated deps
mix hex.outdated

# Update deps
mix deps.update --all
# + npm update ... (phx)
# needs mix_deps hash update

# Removed unused deps
mix deps.clean --unlock --unused

# Check outdated npm packages
npm outdated --prefix assets

# Update npm packages
npm update --prefix assets
```

## Aliases

```sh
# Load the aliases into your shell
# You could also source this in your .profile
. pkg/scripts/alias.sh
```
**Working with aliases**
```sh
# List
alias

# Remove
unalias alias_name

# Remove all
unalias -a
```

## [direnv](https://direnv.net/)

`direnv` let's you automatically load environment variables per directory defined in `.envrc`.

**Working with direnv**
```sh
# Install via Nix
nix-env -iA nixpkgs.direnv

# Setup hook
# Add the following to your .profile
eval "$(direnv hook bash)"
```
