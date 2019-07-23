{ pkgs, elixir, hex, elixir_deps, elixir_build, MIX_ENV, MIX_REBAR3, LANG }:

pkgs.mkShell {
  inherit elixir_deps elixir_build MIX_ENV MIX_REBAR3 LANG;
  nativeBuildInputs = [elixir hex];
  shellHook = ''
    function cleanup() {
      rm -rf deps _build
    }
    trap cleanup EXIT

    mkdir -p deps
    cp -r $elixir_deps/. deps/
    chmod -R 700 deps

    mkdir -p _build
    cp -r $elixir_build/. _build/
    chmod -R 700 _build

    HOME=.
    mix test || exit 1
    echo -e "\e[0;32mtesting succeeded\e[m"
    exit
  '';
}
