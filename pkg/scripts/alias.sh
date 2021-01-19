#!/bin/sh
alias app-env='nix-shell --pure -A env_plain'
# alias app-watch='nix-shell --pure -A dev.watch --option sandbox relaxed'
# alias app-test='nix-shell --pure -A dev.env --argstr environment test --run "mix test" --option sandbox relaxed'
