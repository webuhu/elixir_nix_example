{ config, pkgs, ... }:

{
  nix = {
    package = pkgs.nix_2_4;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  imports = [
    ./hardware-configuration.nix
    /home/main/app/elixir-app/source/pkg/service.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "elixir-app-host";

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
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

  console.keyMap = "de";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Amsterdam";

  # System packages
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Services
  services.caddy = {
    enable = true;
    email = "me@example.com";
    config = ''
      www.example.com {
        redir https://example.com{uri}
      }
      example.com {
        encode gzip
        log
        reverse_proxy localhost:4000
      }
    '';
  };

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "no";

  # User accounts. Don't forget to set a password with with passwd
  users.users.main = {
    isNormalUser = true;
    initialPassword = "main";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [ ];
  };

  security.doas = {
    enable = true;
    extraConfig = ''
      permit persist keepenv main
      permit nopass setenv { NIX_PATH } main cmd nixos-rebuild args switch --impure --relaxed-sandbox
    '';
  };
  security.sudo.enable = false;

  # Automatic `nix-collect-garbage -d`
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 10d";

  # QEMU guest agent
  # https://docs.hetzner.com/de/cloud/technical-details/faq/#wie-sind-unsere-system-images-aufgebaut
  services.qemuGuest.enable = true;
  # for password reset via Hetzner Cloud
  # systemd.services.qemu-guest-agent.path = [ pkgs.shadow ];

  # NixOS State Version
  system.stateVersion = "21.11";
}
