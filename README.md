# Elixir (Phoenix) Nix Example

> Example repo to show off how I use Nix as build environment for Elixir / Phoenix projects.  
> Important Nix stuff is located within `default.nix` & `pkg/` folder.  
This repo is not a working project! It just contains parts of the workflow.

## Note

Since starting this example a lot of positive things have happened or are happening within Nixpkgs.
You may be interestet in `mixRelease` or friends.

I for myself stopped to use a full Nix leveraging build setup. I only use parts of this workflow anymore with reusing local `_build` & `deps` as it speeds up my things for my requirements enorm.

## Setup

This repo provides an easy environment setup by the usage of [Nix](https://nixos.org).  
Nix currently runs on **Linux** and **macOS**.

- [Getting Nix](https://nixos.org/download.html)

By using Nix, beside Nix nothing else needs to be installed manually.

**Windows**  
Recommended also using Nix within a Linux Virtual Machine or WSL 2.

### Manual Setup

For maintaining simplicity, instructions for a manual setup isn't part of this readme.  
Anyway, required dependencies:

- [Elixir](https://elixir-lang.org) (& [Erlang](https://www.erlang.org))
- [PostgreSQL](https://www.postgresql.org)
- [Node.js](https://nodejs.org)

## Development

> For convenience an [alias configuration](#aliases) exists for some of the following shell commands.

### Environment

```sh
# Enter shell w/ development environment (no database)
# Alias: `app-env`
nix-shell --pure -A env

# Run commands without shell
nix-shell --pure -A env --run <command>

# Run commands in interactive shell
nix-shell --pure -A env --cmd <command>

# Enter shell w/ development environment and temporary PostgreSQL database
nix-shell --pure -A env_with_db

# Running all tests
# Alias: `app-test`
nix-shell --pure -A env_with_db --argstr MIX_ENV test --run 'mix test'
```

### Basics commands for working with Elixir / Phoenix

```sh
# Get Elixir mix deps
mix deps.get

# Get JS packages
npm install --prefix assets

# Start Phoenix server
mix phx.server

# Start Elixir application
mix run --no-halt

# Enter IEx
iex -S mix

# Run tests
mix test
```

### Build

```sh
# mix deps
nix-build -A mix_deps --option sandbox relaxed

# JS packages
nix-build -A node_modules --option sandbox relaxed

# Compile
nix-build -A mix_build --option sandbox relaxed

# Compile cacheable -> .nix/_build
nix-shell --pure -A env --command 'mix compile'

# Generate docs using `mix docs`
nix-build -A docs --option sandbox relaxed

# Build procution release using `mix release`
nix-build -A release --argstr MIX_ENV prod --option sandbox relaxed
```

### Maintenance commands

```sh
# Update pinned Nix pkgs
elixir pkg/scripts/pkgs_update.exs

# Check / Update Mix deps
mix hex.outdated
mix deps.update --all

# Removed unused deps from mix.lock
mix deps.clean --unlock --unused

# Check / Update NPM packages
npm outdated --prefix assets
npm update --prefix assets
```

## Aliases

```sh
# Load aliases into your shell
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
