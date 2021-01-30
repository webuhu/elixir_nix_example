#!/bin/sh
alias app-env='nix-shell --pure -A env'
alias app-test='nix-shell --pure -A env_with_db --argstr env test --run "mix test"'
