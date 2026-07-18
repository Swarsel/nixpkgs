{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ifm;
in
{
  options.services.ifm = {
    enable = lib.mkEnableOption ''
      Improved file manager, a single-file web-based filemanager

      Lightweight and minimal, served using PHP's built-in server
    '';

    dataDir = lib.mkOption {
      description = "Directory to serve throught the file managing service";
      type = lib.types.str;
    };

    listenAddress = lib.mkOption {
      default = "127.0.0.1";
      description = "Address on which the service is listening";
      example = "0.0.0.0";
      type = lib.types.str;
    };

    port = lib.mkOption {
      default = 9090;
      description = "Port on which to serve the IFM service";
      type = lib.types.port;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration of the IFM service.

        See [the documentation](https://github.com/misterunknown/ifm/wiki/Configuration)
        for available options and default values.
      '';

      example = {
        IFM_GUI_SHOWPATH = 0;
      };

      type = with lib.types; attrsOf anything;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ifm = {
      after = [ "network-online.target" ];
      description = "Improved file manager, a single-file web based filemanager";

      environment = {
      }
      // (builtins.mapAttrs (_: val: toString val) cfg.settings);

      serviceConfig = {
        BindPaths = "${cfg.dataDir}:/data";
        DynamicUser = true;
        ExecStart = "${lib.getExe pkgs.ifm-web} ${lib.escapeShellArg cfg.listenAddress} ${toString cfg.port} /data";
        PrivateTmp = true;
        StandardOutput = "journal";
        User = "ifm";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ litchipi ];
}
