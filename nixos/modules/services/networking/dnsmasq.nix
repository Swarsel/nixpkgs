{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dnsmasq;
  dnsmasq = cfg.package;
  stateDir = "/var/lib/dnsmasq";

  # True values are just put as `name` instead of `name=true`, and false values
  # are turned to comments (false values are expected to be overrides e.g.
  # lib.mkForce)
  formatKeyValue =
    name: value:
    if value == true then
      name
    else if value == false then
      "# setting `${name}` explicitly set to false"
    else
      lib.generators.mkKeyValueDefault { } "=" name value;

  settingsFormat = pkgs.formats.keyValue {
    listsAsDuplicateKeys = true;
    mkKeyValue = formatKeyValue;
  };

  dnsmasqConf = settingsFormat.generate "dnsmasq.conf" cfg.settings;

in

{

  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "dnsmasq" "servers" ]
      [ "services" "dnsmasq" "settings" "server" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "dnsmasq"
      "extraConfig"
    ] "This option has been replaced by `services.dnsmasq.settings`")
  ];

  ###### interface

  options = {

    services.dnsmasq = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to run dnsmasq.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "dnsmasq" { };

      alwaysKeepRunning = lib.mkOption {
        default = false;

        description = ''
          If enabled, systemd will always respawn dnsmasq even if shut down manually. The default, disabled, will only restart it on error.
        '';

        type = lib.types.bool;
      };

      configFile = lib.mkOption {
        default = dnsmasqConf;
        defaultText = lib.literalExpression "Path of dnsmasq config file";

        description = ''
          Path to the configuration file of dnsmasq.
        '';

        readOnly = true;
        type = lib.types.package;
      };

      resolveLocalQueries = lib.mkOption {
        default = true;

        description = ''
          Whether dnsmasq should resolve local queries (i.e. add 127.0.0.1 to
          /etc/resolv.conf).
        '';

        type = lib.types.bool;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration of dnsmasq. Lists get added one value per line (empty
          lists and false values don't get added, though false values get
          turned to comments). Gets merged with

              {
                dhcp-leasefile = "${stateDir}/dnsmasq.leases";
                conf-file = optional cfg.resolveLocalQueries "/etc/dnsmasq-conf.conf";
                resolv-file = optional cfg.resolveLocalQueries "/etc/dnsmasq-resolv.conf";
              }
        '';

        example = lib.literalExpression ''
          {
            domain-needed = true;
            dhcp-range = [ "192.168.0.2,192.168.0.254" ];
          }
        '';

        type = lib.types.submodule {

          options.server = lib.mkOption {
            default = [ ];

            description = ''
              The DNS servers which dnsmasq should query.
            '';

            example = [
              "8.8.8.8"
              "8.8.4.4"
            ];

            type = lib.types.listOf lib.types.str;
          };

          freeformType = settingsFormat.type;

        };
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    networking.nameservers = lib.optional cfg.resolveLocalQueries "127.0.0.1";

    networking.resolvconf = lib.mkIf cfg.resolveLocalQueries {
      extraConfig = ''
        dnsmasq_conf=/etc/dnsmasq-conf.conf
        dnsmasq_resolv=/etc/dnsmasq-resolv.conf
      '';

      subscriberFiles = [
        "/etc/dnsmasq-conf.conf"
        "/etc/dnsmasq-resolv.conf"
      ];

      useLocalResolver = lib.mkDefault true;
    };

    services.dbus.packages = [ dnsmasq ];

    services.dnsmasq = {
      settings = {
        conf-file = lib.mkDefault (lib.optional cfg.resolveLocalQueries "/etc/dnsmasq-conf.conf");
        dhcp-leasefile = lib.mkDefault "${stateDir}/dnsmasq.leases";
        resolv-file = lib.mkDefault (lib.optional cfg.resolveLocalQueries "/etc/dnsmasq-resolv.conf");
      };
    };

    systemd.services.dnsmasq = {
      after = [
        "network.target"
        "systemd-resolved.service"
      ];

      description = "Dnsmasq Daemon";
      path = [ dnsmasq ];

      preStart = ''
        mkdir -m 755 -p ${stateDir}
        touch ${stateDir}/dnsmasq.leases
        chown -R dnsmasq ${stateDir}
        ${lib.optionalString cfg.resolveLocalQueries "touch /etc/dnsmasq-{conf,resolv}.conf"}
        dnsmasq --test -C ${cfg.configFile}
      '';

      restartTriggers = [ config.environment.etc.hosts.source ];

      serviceConfig = {
        BusName = "uk.org.thekelleys.dnsmasq";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${dnsmasq}/bin/dnsmasq -k --enable-dbus --user=dnsmasq -C ${cfg.configFile}";
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = true;
        Restart = if cfg.alwaysKeepRunning then "always" else "on-failure";
        Type = "dbus";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.dnsmasq = { };

    users.users.dnsmasq = {
      description = "Dnsmasq daemon user";
      group = "dnsmasq";
      isSystemUser = true;
    };
  };

  meta.doc = ./dnsmasq.md;
}
