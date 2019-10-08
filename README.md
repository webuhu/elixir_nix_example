# Seed

> Simple seed to show off how I use Nix as build environment for Elixir projects.

## Setup

This repo provides a quick & easy setup by the usage of [Nix](https://nixos.org/nix/about.html).  
Nix currently runs on **Linux** and **macOS**.

- [Getting Nix](https://nixos.org/nix/download.html)

By using the Nix setup, beside Nix nothing else needs to be manually installed in advance.

**Windows Users**  
We recommended to run the setup within a Linux Virtual Machine or using WSL 2, also using Nix.

### Manual Setup

We don't provide an instruction for manual setup - for maintaining simplicity.  
We just list the required dependencies here:

- [Elixir](https://elixir-lang.org) (& [Erlang](https://www.erlang.org))
- [PostgreSQL](https://www.postgresql.org)

## Development

> For convenience there exists an alias configuration for the following shell commands.  
> Go to: [Aliases](#aliases)

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
nix-shell --pure -A pkgs_update
```

## Aliases

```sh
# Load the aliases into your shell
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
