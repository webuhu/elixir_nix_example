{ pkgs, elixir, hex, deps, build, MIX_ENV, MIX_REBAR3, LANG }:

pkgs.mkShell {
  inherit deps build MIX_ENV MIX_REBAR3 LANG;
  nativeBuildInputs = [elixir hex];
  shellHook = ''
    function cleanup() {
      rm -rf deps _build
    }
    trap cleanup EXIT

    mkdir -p deps
    cp -r $deps/. deps/
    chmod -R 700 deps

    mkdir -p _build
    cp -r $build/. _build/
    chmod -R 700 _build

    HOME=.
    mix test || exit 1
    echo -e "\e[0;32mtesting succeeded\e[m"
    exit
  '';
}
