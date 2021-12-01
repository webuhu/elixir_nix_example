{config, pkgs, lib, ...}:

let
  release = (import ../default.nix { }).release;
  release_name = "elixir-app";
  working_directory = "/home/main/app/elixir-app";
in
{
  systemd.services.${release_name} = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = release_name;
    serviceConfig = {
      Type = "exec";
      User = "main";
      WorkingDirectory = working_directory;
      ExecStart = ''
        ${release}/bin/${release_name} start
      '';
      ExecStop = ''
        ${release}/bin/${release_name} stop
      '';
      ExecReload = ''
        ${release}/bin/${release_name} restart
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };
    # needed for disksup do have sh available
    path = [ pkgs.bash ];
  };

  environment.systemPackages = [ release ];
}
