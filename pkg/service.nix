{config, pkgs, lib, release_name, working_directory, ...}:

let
  release = (import ../default.nix {}).release;
in
{
  "systemd.services.${release_name}" = {
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
      StartLimitBurst = 3;
      StartLimitInterval = 10;
    };
    # needed for disksup do have sh available
    path = [ pkgs.bash ];
  };

  environment.systemPackages = [ release ];
}
