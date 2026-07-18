{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nix.sshServe;
  command =
    if cfg.protocol == "ssh" then
      "nix-store --serve ${lib.optionalString cfg.write "--write"}"
    else
      "nix-daemon --stdio";
in
{
  options = {

    nix.sshServe = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable serving the Nix store as a remote store via SSH.";
        type = lib.types.bool;
      };

      keys = lib.mkOption {
        default = [ ];
        description = "A list of SSH public keys allowed to access the binary cache via SSH.";
        example = [ "ssh-dss AAAAB3NzaC1k... alice@example.org" ];
        type = lib.types.listOf lib.types.str;
      };

      protocol = lib.mkOption {
        default = "ssh";
        description = "The specific Nix-over-SSH protocol to use.";

        type = lib.types.enum [
          "ssh"
          "ssh-ng"
        ];
      };

      trusted = lib.mkOption {
        default = false;
        description = "Whether to add nix-ssh to the nix.settings.trusted-users";
        type = lib.types.bool;
      };

      write = lib.mkOption {
        default = false;
        description = "Whether to enable writing to the Nix store as a remote store via SSH. Note: by default, the sshServe user is named nix-ssh and is not a trusted-user. nix-ssh should be added to the {option}`nix.sshServe.trusted` option in most use cases, such as allowing remote building of derivations to anonymous people based on ssh key";
        type = lib.types.bool;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    nix.settings.trusted-users = lib.mkIf cfg.trusted [ "nix-ssh" ];
    services.openssh.enable = true;

    services.openssh.extraConfig = ''
      Match User nix-ssh
        AllowAgentForwarding no
        AllowTcpForwarding no
        PermitTTY no
        PermitTunnel no
        X11Forwarding no
        ForceCommand ${config.nix.package.out}/bin/${command}
      Match All
    '';

    users.groups.nix-ssh = { };

    users.users.nix-ssh = {
      description = "Nix SSH store user";
      group = "nix-ssh";
      isSystemUser = true;
      shell = pkgs.bashInteractive;
    };

    users.users.nix-ssh.openssh.authorizedKeys.keys = cfg.keys;

  };
}
