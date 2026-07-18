{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.zabbixAgent;

  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    mkMerge
    mkOption
    ;
  inherit (lib)
    attrValues
    literalExpression
    types
    ;
  inherit (lib.generators) toKeyValue;

  user = "zabbix-agent";
  group = "zabbix-agent";

  moduleEnv = pkgs.symlinkJoin {
    name = "zabbix-agent-module-env";
    paths = attrValues cfg.modules;
  };

  configFile = pkgs.writeText "zabbix_agent.conf" (
    toKeyValue { listsAsDuplicateKeys = true; } cfg.settings
  );

in

{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "zabbixAgent"
      "extraConfig"
    ] "Use services.zabbixAgent.settings instead.")
  ];

  # interface

  options = {

    services.zabbixAgent = {
      enable = mkEnableOption "the Zabbix Agent";
      package = mkPackageOption pkgs [ "zabbix" "agent" ] { };

      extraPackages = mkOption {
        default = with pkgs; [ net-tools ];
        defaultText = literalExpression "with pkgs; [ net-tools ]";

        description = ''
          Packages to be added to the Zabbix {env}`PATH`.
          Typically used to add executables for scripts, but can be anything.
        '';

        example = literalExpression "with pkgs; [ net-tools mysql ]";
        type = types.listOf types.package;
      };

      listen = {
        ip = mkOption {
          default = "0.0.0.0";

          description = ''
            List of comma delimited IP addresses that the agent should listen on.
          '';

          type = types.str;
        };

        port = mkOption {
          default = 10050;

          description = ''
            Agent will listen on this port for connections from the server.
          '';

          type = types.port;
        };
      };

      modules = mkOption {
        default = { };
        description = "A set of modules to load.";

        example = literalExpression ''
          {
            "dummy.so" = pkgs.stdenv.mkDerivation {
              name = "zabbix-dummy-module-''${cfg.package.version}";
              src = cfg.package.src;
              buildInputs = [ cfg.package ];
              sourceRoot = "zabbix-''${cfg.package.version}/src/modules/dummy";
              installPhase = '''
                mkdir -p $out/lib
                cp dummy.so $out/lib/
              ''';
            };
          }
        '';

        type = types.attrsOf types.package;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the Zabbix Agent.
        '';

        type = types.bool;
      };

      server = mkOption {
        description = ''
          The IP address or hostname of the Zabbix server to connect to.
        '';

        type = types.str;
      };

      settings = mkOption {
        default = { };

        description = ''
          Zabbix Agent configuration. Refer to
          <https://www.zabbix.com/documentation/current/manual/appendix/config/zabbix_agentd>
          for details on supported values.
        '';

        example = {
          DebugLevel = 4;
          Hostname = "example.org";
        };

        type =
          with types;
          attrsOf (oneOf [
            int
            str
            (listOf str)
          ]);
      };

    };

  };

  # implementation

  config = mkIf cfg.enable {

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen.port ];
    };

    services.zabbixAgent.settings = mkMerge [
      {
        ListenPort = cfg.listen.port;
        LogType = "console";
        Server = cfg.server;
      }
      (mkIf (cfg.modules != { }) {
        LoadModule = builtins.attrNames cfg.modules;
        LoadModulePath = "${moduleEnv}/lib";
      })

      # the default value for "ListenIP" is 0.0.0.0 but zabbix agent 2 cannot accept configuration files which
      # explicitly set "ListenIP" to the default value...
      (mkIf (cfg.listen.ip != "0.0.0.0") { ListenIP = cfg.listen.ip; })
    ];

    systemd.services.zabbix-agent = {
      description = "Zabbix Agent";

      # https://www.zabbix.com/documentation/current/manual/config/items/userparameters
      # > User parameters are commands executed by Zabbix agent.
      # > /bin/sh is used as a command line interpreter under UNIX operating systems.
      path =
        with pkgs;
        [
          bash
          "/run/wrappers"
        ]
        ++ cfg.extraPackages;

      serviceConfig = {
        ExecStart = "@${cfg.package}/sbin/zabbix_agentd zabbix_agentd -f --config ${configFile}";
        Group = group;
        PrivateTmp = true;
        Restart = "always";
        RestartSec = 2;
        User = user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${group} = { };

    users.users.${user} = {
      inherit group;
      description = "Zabbix Agent daemon user";
      isSystemUser = true;
    };

  };

}
