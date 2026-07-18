{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.atalkd;

  # Generate atalkd.conf only if configFile isn't manually specified
  atalkdConfFile = pkgs.writeText "atalkd.conf" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        iface: ifaceCfg: iface + (if ifaceCfg.config != null then " ${ifaceCfg.config}" else "")
      ) cfg.interfaces
    )
  );
in
{
  options.services.atalkd = {
    enable = lib.mkEnableOption "the AppleTalk daemon";

    configFile = lib.mkOption {
      default = atalkdConfFile;
      defaultText = "/nix/store/xxx-atalkd.conf";

      description = ''
        Optional path to a custom {file}`atalkd.conf` file. When set, this overrides the generated
        configuration from `services.atalkd.interfaces`.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    interfaces = lib.mkOption {
      default = { };
      description = "Per-interface configuration for atalkd.";

      type = lib.types.attrsOf (
        lib.types.submodule {
          options.config = lib.mkOption {
            default = null;
            description = "Optional configuration string for this interface.";
            type = lib.types.nullOr lib.types.str;
          };
        }
      );
    };
  };

  config =
    let
      interfaces = map (iface: "sys-subsystem-net-devices-${utils.escapeSystemdPath iface}.device") (
        builtins.attrNames cfg.interfaces
      );
    in
    lib.mkIf cfg.enable {
      system.requiredKernelConfig = [
        (config.lib.kernelConfig.isEnabled "APPLETALK")
      ];

      systemd.services.atalkd =
        let
          interfaces = map (iface: "sys-subsystem-net-devices-${utils.escapeSystemdPath iface}.device") (
            builtins.attrNames cfg.interfaces
          );
        in
        {

          after = interfaces;
          before = [ "netatalk.service" ];
          description = "atalkd AppleTalk daemon";
          path = [ pkgs.netatalk ];
          requires = interfaces;

          serviceConfig = {
            AmbientCapabilities = [ "CAP_NET_ADMIN" ];
            BindPaths = [ "/run/atalkd:/run/lock" ];
            DynamicUser = true;
            ExecStart = "${pkgs.netatalk}/bin/atalkd -f ${cfg.configFile}";
            GuessMainPID = "no";
            PIDFile = "/run/atalkd/atalkd";
            Restart = "always";
            RuntimeDirectory = "atalkd";
            Type = "forking";
          };

          unitConfig.Documentation = "man:atalkd.conf(5) man:atalkd(8)";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network.target" ];
        };

      systemd.services.netatalk.after = interfaces;
      systemd.services.netatalk.partOf = [ "atalkd.service" ];
      systemd.services.netatalk.requires = interfaces;
    };

  meta.doc = ./atalkd.md;
  meta.maintainers = with lib.maintainers; [ matthewcroughan ];
}
