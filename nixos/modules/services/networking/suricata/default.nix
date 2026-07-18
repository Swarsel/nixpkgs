{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.suricata;
  pkg = cfg.package;
  yaml = pkgs.formats.yaml { };
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    literalExpression
    filterAttrsRecursive
    concatStringsSep
    strings
    lists
    mkIf
    ;
in
{
  options.services.suricata = {
    enable = mkEnableOption "Suricata";
    package = mkPackageOption pkgs "suricata" { };

    configFile = mkOption {
      default =
        pkgs.runCommand "suricata.yaml"
          {
            settingsYaml = yaml.generate "suricata-settings-raw.yaml" (
              filterAttrsRecursive (name: value: value != null) cfg.settings
            );
          }
          ''
            echo "%YAML 1.1" > $out
            echo "---" >> $out
            cat $settingsYaml >> $out
          '';

      description = ''
        Configuration file for suricata.

        It is not usual to override the default values; it is recommended to use `settings`.
        If you want to include extra configuration to the file, use the `settings.includes`.
      '';

      type = types.path;
      visible = false;
    };

    disabledRules = mkOption {
      # protocol dnp3 seams to be disabled, which causes the signature evaluation to fail, so we disable the
      # dnp3 rules, see https://github.com/OISF/suricata/blob/master/rules/dnp3-events.rules for more details
      default = [
        "2270000"
        "2270001"
        "2270002"
        "2270003"
        "2270004"
      ];

      description = ''
        List of rules that should be disabled.
      '';

      type = types.listOf types.str;
    };

    enabledSources = mkOption {
      # see: nix-shell -p suricata python3Packages.pyyaml --command 'suricata-update list-sources'
      default = [
        "abuse.ch/sslbl-blacklist"
        "abuse.ch/sslbl-c2"
        "abuse.ch/sslbl-ja3"
        "et/open"
        "etnetera/aggressive"
        "stamus/lateral"
        "oisf/trafficid"
        "tgreen/hunting"
        "pawpatrules"
        "ptrules/open"
      ];

      description = ''
        List of sources that should be enabled.
        Currently sources which require a secret-code are not supported.
      '';

      type = types.listOf types.str;
    };

    settings = mkOption {
      description = "Suricata settings";

      example = literalExpression ''
        vars.address-groups.HOME_NET = "192.168.178.0/24";
        outputs = [
          {
            fast = {
              enabled = true;
              filename = "fast.log";
              append = "yes";
            };
          }
          {
            eve-log = {
              enabled = true;
              filetype = "regular";
              filename = "eve.json";
              community-id = true;
              types = [
                {
                  alert.tagged-packets = "yes";
                }
              ];
            };
          }
        ];
        af-packet = [
          {
            interface = "eth0";
            cluster-id = "99";
            cluster-type = "cluster_flow";
            defrag = "yes";
          }
          {
            interface = "default";
          }
        ];
        af-xdp = [
          {
            interface = "eth1";
          }
        ];
        dpdk.interfaces = [
          {
            interface = "eth2";
          }
        ];
        pcap = [
          {
            interface = "eth3";
          }
        ];
        app-layer.protocols = {
          telnet.enabled = "yes";
          dnp3.enabled = "yes";
          modbus.enabled = "yes";
        };
      '';

      type = types.submodule (import ./settings.nix { inherit config lib yaml; });
    };
  };

  config =
    let
      captureInterfaces =
        let
          inherit (lists) unique optionals;
        in
        unique (
          map (e: e.interface) (
            (optionals (cfg.settings.af-packet != null) cfg.settings.af-packet)
            ++ (optionals (cfg.settings.af-xdp != null) cfg.settings.af-xdp)
            ++ (optionals (
              cfg.settings.dpdk != null && cfg.settings.dpdk.interfaces != null
            ) cfg.settings.dpdk.interfaces)
            ++ (optionals (cfg.settings.pcap != null) cfg.settings.pcap)
          )
        );
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = (builtins.length captureInterfaces) > 0;

          message = ''
            At least one capture interface must be configured:
            - `services.suricata.settings.af-packet`
            - `services.suricata.settings.af-xdp`
            - `services.suricata.settings.dpdk.interfaces`
            - `services.suricata.settings.pcap`
          '';
        }
      ];

      boot.kernelModules = mkIf (cfg.settings.af-packet != null) [ "af_packet" ];

      systemd.services = {
        suricata = {
          after = [ "suricata-update.service" ];
          description = "Suricata";

          serviceConfig =
            let
              interfaceOptions = strings.concatMapStrings (interface: " -i ${interface}") captureInterfaces;
            in
            {
              DevicePolicy = "closed";
              ExecStart = "!${pkg}/bin/suricata -c ${cfg.configFile}${interfaceOptions}";
              ExecStartPre = "!${pkg}/bin/suricata -c ${cfg.configFile} -T";
              Group = cfg.settings.run-as.group;
              LockPersonality = true;
              MemoryDenyWriteExecute = true;
              NoNewPrivileges = true;
              PrivateDevices = true;
              PrivateIPC = true;
              PrivateTmp = true;
              ProcSubset = "pid";
              ProtectControlGroups = true;
              ProtectHostname = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              ProtectProc = true;
              ProtectSystem = "strict";
              ReadOnlyPaths = cfg.configFile;
              ReadWritePaths = cfg.settings."default-log-dir";
              RemoveIPC = true;
              Restart = "on-failure";
              RestrictNamespaces = true;
              RestrictRealtime = true;
              RestrictSUIDSGID = true;
              RuntimeDirectory = "suricata";
              SystemCallArchitectures = "native";
              User = cfg.settings.run-as.user;
            };

          wantedBy = [ "multi-user.target" ];
        };

        suricata-update = {
          after = [ "network-online.target" ];
          description = "Update Suricata Rules";

          script =
            let
              python = pkgs.python3.withPackages (ps: with ps; [ pyyaml ]);
              enabledSourcesCmds = map (
                src: "${python.interpreter} ${pkg}/bin/suricata-update enable-source ${src}"
              ) cfg.enabledSources;
            in
            ''
              ${concatStringsSep "\n" enabledSourcesCmds}
              ${python.interpreter} ${pkg}/bin/suricata-update update-sources
              ${python.interpreter} ${pkg}/bin/suricata-update update --suricata-conf ${cfg.configFile} --no-test \
                --disable-conf ${pkgs.writeText "suricata-disable-conf" "${concatStringsSep "\n" cfg.disabledRules}"}
            '';

          serviceConfig = {
            DynamicUser = true;
            Group = cfg.settings.run-as.group;
            PrivateDevices = true;
            PrivateIPC = true;
            PrivateTmp = true;
            ReadOnlyPaths = cfg.configFile;

            ReadWritePaths = [
              "/var/lib/suricata"
              cfg.settings."default-rule-path"
            ];

            Type = "oneshot";
            User = cfg.settings.run-as.user;
          };

          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
        };
      };

      systemd.timers = {
        suricata-update = {
          timerConfig = {
            OnBootSec = lib.mkDefault "30s";
            OnUnitActiveSec = lib.mkDefault "24h";
            Persistent = true;
            Unit = config.systemd.services.suricata-update.name;
          };
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.settings."default-log-dir"} 755 ${cfg.settings.run-as.user} ${cfg.settings.run-as.group}"
        "d /var/lib/suricata 755 ${cfg.settings.run-as.user} ${cfg.settings.run-as.group}"
        "d ${cfg.settings."default-rule-path"} 755 ${cfg.settings.run-as.user} ${cfg.settings.run-as.group}"
      ];

      users = {
        groups.${cfg.settings.run-as.group} = { };

        users.${cfg.settings.run-as.user} = {
          group = cfg.settings.run-as.group;
          isSystemUser = true;
        };
      };
    };

  meta.maintainers = with lib.maintainers; [ felbinger ];
}
