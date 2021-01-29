{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    /home/main/app/elixir-app/source/pkg/service.nix {
      release_name = "elixir-app";
      working_directory = "/home/main/app/elixir-app";
    }
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [ "/dev/sda" ];

  networking.hostName = "elixir-app-host";

  networking.firewall = {
    allowedTCPPorts = [ 80 443 4080 4443 ];
  };

  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  # IPv6
  networking.interfaces.ens3.ipv6.addresses = [{
    address = "<EDIT: Insert your desired IPv6 address>";
    prefixLength = 64;
  }];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens3";
  };

  # Port forwarding
  networking.firewall.extraPackages = [ pkgs.iptables ];
  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 80 -j REDIRECT --to-ports 4080
    iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 443 -j REDIRECT --to-ports 4443
    ip6tables -t nat -A PREROUTING -i ens3 -p tcp --dport 80 -j REDIRECT --to-ports 4080
    ip6tables -t nat -A PREROUTING -i ens3 -p tcp --dport 443 -j REDIRECT --to-ports 4443
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D PREROUTING -i ens3 -p tcp --dport 80 -j REDIRECT --to-ports 4080 || true
    iptables -t nat -D PREROUTING -i ens3 -p tcp --dport 443 -j REDIRECT --to-ports 4443 || true
    ip6tables -t nat -D PREROUTING -i ens3 -p tcp --dport 80 -j REDIRECT --to-ports 4080 || true
    ip6tables -t nat -D PREROUTING -i ens3 -p tcp --dport 443 -j REDIRECT --to-ports 4443 || true
  '';

  console.keyMap = "de";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Amsterdam";

  # System packages
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Services
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "no";

  # User accounts. Don't forget to set a password with with passwd
  users.users.main = {
    uid = 100;
    isNormalUser = true;
    initialPassword = "main";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [];
  };

  security.sudo.extraConfig = ''
    main ALL= NOPASSWD: /run/current-system/sw/bin/nixos-rebuild switch
    main ALL= NOPASSWD: /run/current-system/sw/bin/systemctl * elixir-app
  '';

  # Automatic `nix-collect-garbage -d`
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";

  # QEMU guest agent
  # https://docs.hetzner.com/de/cloud/technical-details/faq/#wie-sind-unsere-system-images-aufgebaut
  services.qemuGuest.enable = true;
  # for password reset via Hetzner Cloud
  # systemd.services.qemu-guest-agent.path = [ pkgs.shadow ];

  # NixOS State Version
  system.stateVersion = "20.09";
}
