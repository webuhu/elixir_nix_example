#!/bin/sh
alias app-setup='nix-build -A elixir_prepare --option sandbox relaxed'
alias app-env='nix-shell --pure -A env'
alias app-watch='nix-shell --pure -A dev.watch --option sandbox relaxed'
alias app-test='nix-shell --pure -A dev.env --argstr environment test --run "mix test" --option sandbox relaxed'
