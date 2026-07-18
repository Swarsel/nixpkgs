# Fusion Inventory daemon.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fusionInventory;

  configFile = pkgs.writeText "fusion_inventory.conf" ''
    server = ${lib.concatStringsSep ", " cfg.servers}

    logger = stderr

    ${cfg.extraConfig}
  '';

in
{

  ###### interface

  options = {

    services.fusionInventory = {

      enable = lib.mkEnableOption "Fusion Inventory Agent";

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Configuration that is injected verbatim into the configuration file.
        '';

        type = lib.types.lines;
      };

      servers = lib.mkOption {
        description = ''
          The urls of the OCS/GLPI servers to connect to.
        '';

        type = lib.types.listOf lib.types.str;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.fusion-inventory = {
      description = "Fusion Inventory Agent";

      serviceConfig = {
        ExecStart = "${pkgs.fusioninventory-agent}/bin/fusioninventory-agent --conf-file=${configFile} --daemon --no-fork";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.users.fusion-inventory = {
      description = "FusionInventory user";
      isSystemUser = true;
    };
  };
}
