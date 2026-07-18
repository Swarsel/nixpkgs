{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
  paths = pkgs.buildEnv {
    name = "firewalld-paths";
    paths = cfg.packages;
    pathsToLink = [ "/lib/firewalld" ];
  };
in
{
  imports = [
    ./service.nix
    ./settings.nix
    ./zone.nix
  ];

  options.services.firewalld = {
    enable = lib.mkEnableOption "FirewallD";
    package = lib.mkPackageOption pkgs "firewalld" { };

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Extra arguments to pass to FirewallD.";
      example = [ "--debug" ];
      type = lib.types.listOf lib.types.str;
    };

    packages = lib.mkOption {
      default = [ ];

      description = ''
        Packages providing firewalld zones and other files.
        Files found in `/lib/firewalld` will be included.
      '';

      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."sysconfig/firewalld".text = ''
      FIREWALLD_ARGS=${lib.concatStringsSep " " cfg.extraArgs}
    '';

    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];
    services.firewalld.packages = [ cfg.package ];

    services.logrotate.settings."/var/log/firewalld" = {
      copytruncate = true;
      minsize = "1M";
    };

    systemd.packages = [ cfg.package ];

    systemd.services.firewalld = {
      aliases = [ "dbus-org.fedoraproject.FirewallD1.service" ];
      environment.NIX_FIREWALLD_CONFIG_PATH = "${paths}/lib/firewalld";

      reloadTriggers = [
        config.environment.etc."firewalld/firewalld.conf".source
      ]
      ++ lib.mapAttrsToList (
        name: _: config.environment.etc."firewalld/zones/${name}.xml".source
      ) config.services.firewalld.zones
      ++ lib.mapAttrsToList (
        name: _: config.environment.etc."firewalld/services/${name}.xml".source
      ) config.services.firewalld.services;

      serviceConfig.ExecReload = [
        ""
        "${lib.getExe' pkgs.coreutils "kill"} -HUP $MAINPID"
      ];

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ prince213 ];
}
