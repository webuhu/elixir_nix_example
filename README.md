# Elixir (Phoenix) Nix Example

> Example repo to show off how I use Nix as build environment for Elixir / Phoenix projects.  
> Important Nix stuff is located within `flake.nix` / `default.nix` & `pkg/` folder.  
This repo is not a working project! It just contains parts of the workflow.

**Note**

Since starting this example a lot of positive things have happened or are happening within Nixpkgs.
You may be interested in `mixRelease` or friends.

I for myself stopped to use a full Nix leveraging build setup. I only use parts of this workflow anymore with reusing local `_build` & `deps` as it speeds up things for my requirements enorm.

---

## Setup

This repo provides an easy environment setup by the usage of [Nix](https://nixos.org) (w/ flakes enabled).  
Nix currently runs on **Linux** and **macOS**.

- [Getting Nix](https://nixos.org/download.html)

**Enabling Nix flakes (Nix v2.4)**
```
# ~/.config/nix/nix.conf
experimental-features = nix-command flakes
```

By using Nix, beside Nix nothing else needs to be installed manually.

**Windows**  
Recommended also using Nix within a Linux Virtual Machine or WSL 2.

### Manual Setup

For maintaining simplicity, instructions for a manual setup isn't part of this readme.  
Anyway, required dependencies:

- [Elixir](https://elixir-lang.org) (& [Erlang](https://www.erlang.org))
- [PostgreSQL](https://www.postgresql.org)
- ([Node.js](https://nodejs.org))

## Development

### Environment

```sh
# Enter shell w/ development environment + temporary PostgreSQL database
nix develop

# Run commands without shell
nix develop --command <command>
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
nix build --file default.nix mix_deps --relaxed-sandbox

# JS packages
nix build --file default.nix node_modules --relaxed-sandbox

# Compile
nix build --file default.nix mix_build --relaxed-sandbox

# Compile cacheable `_build`
nix develop --command mix compile

# Generate docs using `mix docs`
nix build --file default.nix docs --relaxed-sandbox

# Build production release using `mix release`
nix build --file default.nix release --relaxed-sandbox
```

### Maintenance

```sh
# Update pinned Nix pkgs
elixir pkg/scripts/pkgs_update.exs
# Update flake.lock
nix flake update

# Check / update / clean Mix deps
mix hex.outdated
mix deps.update --all
mix deps.clean --unlock --unused

# Check / update / clean NPM packages
npm outdated --prefix assets
npm update --prefix assets
npm prune --prefix assets

# Flake checks
nix flake check
```

## [direnv](https://direnv.net/)

`direnv` let's you automatically load environment variables per directory defined in `.envrc`.

**Working with direnv**
```sh
# Install via Nix
nix profile install nixpkgs#direnv

# Setup hook
# Add the following to your .profile
eval "$(direnv hook bash)"
```
