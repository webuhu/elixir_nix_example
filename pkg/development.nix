# legacy setup
# decide if watchexc is still useful
{ pkgs, elixir, hex, postgresql, elixir_prepare, MIX_ENV, MIX_REBAR3, LANG }:

rec {
  watchexec = pkgs.watchexec;

  elixir_setup = ''
    ${elixir_import_deps}
    ${elixir_import_build}

    mix ecto.migrate --quiet
    # mix phx.server

    cleanup_elixir() {
      echo 'cleanup elixir ...'

      rm -rf deps _build
    }
  '';

  watch = pkgs.mkShell {
    inherit elixir_prepare MIX_ENV MIX_REBAR3 LANG;
    CLEANED_ERL_LIBS = "${hex}/lib/erlang/lib";
    nativeBuildInputs = [elixir hex postgresql watchexec];
    shellHook = ''
      export ERL_LIBS=$CLEANED_ERL_LIBS

      ${shell_setup}
      ${elixir_setup}

      trap cleanup_elixir EXIT

      echo -e "\e[0;32mwatch mode starting ...\e[m"
      watchexec --exts ex --restart "mix run --no-halt &"
    '';
  };
}
