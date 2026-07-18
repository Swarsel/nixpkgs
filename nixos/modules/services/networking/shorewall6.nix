{
  config,
  lib,
  pkgs,
  ...
}:
let
  types = lib.types;
  cfg = config.services.shorewall6;
in
{
  options = {
    services.shorewall6 = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable Shorewall IPv6 Firewall.

          ::: {.warning}
          Enabling this service WILL disable the existing NixOS
          firewall! Default firewall rules provided by packages are not
          considered at the moment.
          :::
        '';

        type = types.bool;
      };

      package = lib.mkPackageOption pkgs "shorewall" { };

      configs = lib.mkOption {
        apply = lib.mapAttrs (name: text: pkgs.writeText "${name}" text);
        default = { };

        description = ''
          This option defines the Shorewall configs.
          The attribute name defines the name of the config,
          and the attribute value defines the content of the config.
        '';

        type = types.attrsOf types.lines;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc = lib.mapAttrs' (
        name: conf: lib.nameValuePair "shorewall6/${name}" { source = conf; }
      ) cfg.configs;

      systemPackages = [ cfg.package ];
    };

    systemd.services.firewall.enable = false;

    systemd.services.shorewall6 = {
      after = [ "ipset.target" ];
      before = [ "network-pre.target" ];
      description = "Shorewall IPv6 Firewall";

      preStart = ''
        install -D -d -m 750 /var/lib/shorewall6
        install -D -d -m 755 /var/lock/subsys
        touch                /var/log/shorewall6.log
        chmod 750            /var/log/shorewall6.log
      '';

      reloadIfChanged = true;
      restartTriggers = lib.attrValues cfg.configs;

      serviceConfig = {
        ExecReload = "${cfg.package}/bin/shorewall6 reload";
        ExecStart = "${cfg.package}/bin/shorewall6 start";
        ExecStop = "${cfg.package}/bin/shorewall6 stop";
        RemainAfterExit = "yes";
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-pre.target" ];
    };
  };
}
