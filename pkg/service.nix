{config, pkgs, lib, ...}:

let
  release = (import ../default.nix {}).release;
in
{
  systemd.services.elixir-app = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "elixir-app release";
    serviceConfig = {
      Type = "exec";
      User = "main";
      WorkingDirectory = "/home/main/app/elixir-app";
      ExecStart = ''
        ${release}/bin/elixir-app start
      '';
      ExecStop = ''
        ${release}/bin/elixir-app stop
      '';
      ExecReload = ''
        ${release}/bin/elixir-app restart
      '';
      Restart = "on-failure";
      RestartSec = 5;
      StartLimitBurst = 3;
      StartLimitInterval = 10;
    };
    # needed for disksup do have sh available
    path = [ pkgs.bash ];
  };

  environment.systemPackages = [ release ];
}
