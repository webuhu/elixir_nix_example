# Elixir (Phoenix) Nix Example

> Simple example repo to show off how I use Nix as build environment for Elixir projects.

## Setup

This repo provides a quick & easy setup by the usage of [Nix](https://nixos.org).  
Nix currently runs on **Linux** and **macOS**.

- [Getting Nix](https://nixos.org/download.html)

By using Nix, beside Nix nothing else needs to be manually installed.

**Windows Users**  
Recommended to run the setup, also using Nix, within a Linux Virtual Machine or using WSL 2.

### Manual Setup

For maintaining simplicity, instructions for a manual setup isn't part of the documentation.  
Anyway, required dependencies:

- [Elixir](https://elixir-lang.org) (& [Erlang](https://www.erlang.org))
- [PostgreSQL](https://www.postgresql.org)
- [Node.js](https://nodejs.org)

## Development

> For convenience an [alias configuration](#aliases) exists for most of the following shell commands.

### Environment

```sh
# Elixir Setup (get deps & compile)
# Necessary before running most of the following commands,
# as `mix deps.get` is seen as an impure fetch
# Alias: `app-setup`
nix-build -A elixir_prepare --option sandbox relaxed

# Enter shell w/ development environment
# Alias: `app-env`
nix-shell --pure -A dev.env

# Run app
# Alias: `app-run`
nix-shell --pure -A dev.env --run 'mix run --no-halt'

# Enter IEx (Elixir's interactive shell)
# Alias: `app-iex`
nix-shell --pure -A dev.env --run 'iex -S mix'

# Start development watch mode
# Alias: `app-watch`
nix-shell --pure -A dev.watch
```

### Test

```sh
# Running all tests
# Alias: `app-test`
nix-shell --pure -A dev.env --argstr environment test --run 'mix test'
```

### Docs

```sh
# Generate docs using `mix docs`
nix-build -A docs.build
```

### Release

```sh
# Build procution release using `mix release`
nix-build -A release --argstr environment prod --argstr release_name seed
```

### Maintenance

```sh
# Update pinned Nix packages
elixir pkg/scripts/pkgs_update.exs

# Check outdated deps
mix hex.outdated

# Update deps
mix deps.update --all

# Removed unused deps from mix.lock
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
