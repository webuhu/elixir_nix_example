{ pkgs ? import ./pkg/_pkgs.nix, MIX_ENV ? "dev", release_name ? "example" }:

rec {
  erlang = pkgs.beam.interpreters.erlangR24;
  # BEAM no X versions are not in cache - needs to build yourself
  # erlang = pkgs.beam_nox.interpreters.erlangR24;
  elixir = pkgs.beam.packages.erlangR24.elixir_1_12;
  # BEAM no X versions are not in cache - needs to build yourself
  # elixir = pkgs.beam_nox.packages.erlangR24.elixir_1_12;
  nodejs = pkgs.nodejs-16_x;

  MIX_HOME = hex;
  MIX_REBAR3 = "${rebar3}/bin/rebar3";
  LANG = "C.UTF-8";

  # This is opinionated instead of simple using:
  # hex = pkgs.beam.packages.erlang.hex;
  hex = pkgs.callPackage ./pkg/hex.nix {
    inherit elixir;
  };

  # This is opinionated instead of simple using:
  # rebar3 = pkgs.beam.packages.erlang.rebar3;
  rebar3 = pkgs.callPackage ./pkg/rebar3.nix {
    inherit erlang;
  };

  # Needs `--option sandbox relaxed` if used without setting hash (impure fetch)
  mix_deps = pkgs.callPackage ./pkg/mix_deps_get.nix {
    inherit elixir MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    # hash is also changing with env
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  # Needs `--option sandbox relaxed` if used without setting hash (impure fetch)
  mix_deps_build = pkgs.callPackage ./pkg/mix_deps_compile.nix {
    inherit elixir MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    inherit mix_deps;
    # hash is also changing with env
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  # Needs `--option sandbox relaxed` if used without setting hash (impure fetch)
  mix_build = pkgs.callPackage ./pkg/mix_compile.nix {
    inherit elixir MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    inherit mix_deps mix_deps_build;
    # hash is also changing with env
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  # Needs `--option sandbox relaxed` if used without setting hash (impure fetch)
  node_modules = pkgs.callPackage ./pkg/node_modules.nix {
    inherit nodejs;
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  # Needs `--option sandbox relaxed` if used without setting hash & hashed inputs (impure fetch)
  # Works probably only for env "dev" → mix.exs
  docs = pkgs.callPackage ./pkg/mix_docs.nix {
    inherit elixir MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    inherit mix_deps mix_build;
    # hash is also changing with env
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  # Needs `--option sandbox relaxed` if used without setting hash & hashed inputs (impure fetch)
  release = pkgs.callPackage ./pkg/mix_release.nix {
    inherit elixir MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    inherit mix_deps mix_build release_name;
    inherit node_modules;
    inherit nodejs;
    # hash is also changing with env & release_name
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };
}
