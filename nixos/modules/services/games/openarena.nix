{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.openarena;
in
{
  options = {
    services.openarena = {
      enable = mkEnableOption "OpenArena game server";
      package = lib.mkPackageOption pkgs "openarena" { };

      extraFlags = mkOption {
        default = [ ];
        description = "Extra flags to pass to {command}`oa_ded`";

        example = [
          "+set dedicated 2"
          "+set sv_hostname 'My NixOS OpenArena Server'"
          # Load a map. Mandatory for clients to be able to connect.
          "+map oa_dm1"
        ];

        type = types.listOf types.str;
      };

      openPorts = mkOption {
        default = false;
        description = "Whether to open firewall ports for OpenArena";
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openPorts {
      allowedUDPPorts = [ 27960 ];
    };

    systemd.services.openarena = {
      after = [ "network.target" ];
      description = "OpenArena";

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/oa_ded +set fs_basepath ${cfg.package}/share/openarena +set fs_homepath /var/lib/openarena ${concatStringsSep " " cfg.extraFlags}";
        NoNewPrivileges = true;
        PrivateDevices = true;
        Restart = "on-failure";
        StateDirectory = "openarena";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
