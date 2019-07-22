# Seed

> Simple seed to show off how I use Nix as build environment for Elixir projects.

## Getting started

The easiest way to get the app running is by the usage of [Nix](https://nixos.org/nix/download.html) on a *nix system.

### Development commands
- `nix-shell -A development.run` - run app
- `nix-shell -A development.watch` - start development watch mode
- `nix-shell -A development.env` - enter shell w/ Elixir
- `nix-shell -A development.iex` - enter IEx shell
- `nix-build -A docs` - generate doc

### Testing
- `nix-shell -A testing --argstr environment test` - run tests

### Release commands
- `nix-build -A release --argstr environment prod` - build production release

### Maintenance commands
- `nix-shell -A pkgs_update` - update Nix packages
