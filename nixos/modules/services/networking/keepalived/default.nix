{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.keepalived;

  keepalivedConf = pkgs.writeText "keepalived.conf" ''
    global_defs {
      ${optionalString cfg.enableScriptSecurity "enable_script_security"}
      ${snmpGlobalDefs}
      ${cfg.extraGlobalDefs}
    }

    ${vrrpScriptStr}
    ${vrrpInstancesStr}
    ${cfg.extraConfig}
  '';

  snmpGlobalDefs =
    with cfg.snmp;
    optionalString enable (
      optionalString (socket != null) "snmp_socket ${socket}\n"
      + optionalString enableKeepalived "enable_snmp_keepalived\n"
      + optionalString enableChecker "enable_snmp_checker\n"
      + optionalString enableRfc "enable_snmp_rfc\n"
      + optionalString enableRfcV2 "enable_snmp_rfcv2\n"
      + optionalString enableRfcV3 "enable_snmp_rfcv3\n"
      + optionalString enableTraps "enable_traps"
    );

  vrrpScriptStr = concatStringsSep "\n" (
    map (s: ''
      vrrp_script ${s.name} {
        script "${s.script}"
        interval ${toString s.interval}
        fall ${toString s.fall}
        rise ${toString s.rise}
        timeout ${toString s.timeout}
        weight ${toString s.weight}
        user ${s.user} ${optionalString (s.group != null) s.group}

        ${s.extraConfig}
      }
    '') vrrpScripts
  );

  vrrpInstancesStr = concatStringsSep "\n" (
    map (i: ''
      vrrp_instance ${i.name} {
        interface ${i.interface}
        state ${i.state}
        virtual_router_id ${toString i.virtualRouterId}
        priority ${toString i.priority}
        ${optionalString i.noPreempt "nopreempt"}

        ${optionalString i.useVmac (
          "use_vmac" + optionalString (i.vmacInterface != null) " ${i.vmacInterface}"
        )}
        ${optionalString i.vmacXmitBase "vmac_xmit_base"}

        ${optionalString (i.unicastSrcIp != null) "unicast_src_ip ${i.unicastSrcIp}"}
        ${optionalString (builtins.length i.unicastPeers > 0) ''
          unicast_peer {
            ${concatStringsSep "\n" i.unicastPeers}
          }
        ''}

        virtual_ipaddress {
          ${concatMapStringsSep "\n" virtualIpLine i.virtualIps}
        }

        ${optionalString (builtins.length i.trackScripts > 0) ''
          track_script {
            ${concatStringsSep "\n" i.trackScripts}
          }
        ''}

        ${optionalString (builtins.length i.trackInterfaces > 0) ''
          track_interface {
            ${concatStringsSep "\n" i.trackInterfaces}
          }
        ''}

        ${i.extraConfig}
      }
    '') vrrpInstances
  );

  virtualIpLine =
    ip:
    ip.addr
    + optionalString (notNullOrEmpty ip.brd) " brd ${ip.brd}"
    + optionalString (notNullOrEmpty ip.dev) " dev ${ip.dev}"
    + optionalString (notNullOrEmpty ip.scope) " scope ${ip.scope}"
    + optionalString (notNullOrEmpty ip.label) " label ${ip.label}";

  notNullOrEmpty = s: !(s == null || s == "");

  vrrpScripts = mapAttrsToList (
    name: config:
    {
      inherit name;
    }
    // config
  ) cfg.vrrpScripts;

  vrrpInstances = mapAttrsToList (
    iName: iConfig:
    {
      name = iName;
    }
    // iConfig
  ) cfg.vrrpInstances;

  vrrpInstanceAssertions =
    i:
    [
      {
        assertion = i.interface != "";
        message = "services.keepalived.vrrpInstances.${i.name}.interface option cannot be empty.";
      }
      {
        assertion = i.virtualRouterId >= 0 && i.virtualRouterId <= 255;
        message = "services.keepalived.vrrpInstances.${i.name}.virtualRouterId must be an integer between 0..255.";
      }
      {
        assertion = i.priority >= 0 && i.priority <= 255;
        message = "services.keepalived.vrrpInstances.${i.name}.priority must be an integer between 0..255.";
      }
      {
        assertion = i.vmacInterface == null || i.useVmac;
        message = "services.keepalived.vrrpInstances.${i.name}.vmacInterface has no effect when services.keepalived.vrrpInstances.${i.name}.useVmac is not set.";
      }
      {
        assertion = !i.vmacXmitBase || i.useVmac;
        message = "services.keepalived.vrrpInstances.${i.name}.vmacXmitBase has no effect when services.keepalived.vrrpInstances.${i.name}.useVmac is not set.";
      }
    ]
    ++ flatten (map (virtualIpAssertions i.name) i.virtualIps)
    ++ flatten (map (vrrpScriptAssertion i.name) i.trackScripts);

  virtualIpAssertions = vrrpName: ip: [
    {
      assertion = ip.addr != "";
      message = "The 'addr' option for an services.keepalived.vrrpInstances.${vrrpName}.virtualIps entry cannot be empty.";
    }
  ];

  vrrpScriptAssertion = vrrpName: scriptName: {
    assertion = builtins.hasAttr scriptName cfg.vrrpScripts;
    message = "services.keepalived.vrrpInstances.${vrrpName} trackscript ${scriptName} is not defined in services.keepalived.vrrpScripts.";
  };

  pidFile = "/run/keepalived.pid";

in
{
  options = {
    services.keepalived = {

      enable = mkOption {
        default = false;

        description = ''
          Whether to enable Keepalived.
        '';

        type = types.bool;
      };

      package = lib.mkPackageOption pkgs "keepalived" { };

      enableScriptSecurity = mkOption {
        default = false;

        description = ''
          Don't run scripts configured to be run as root if any part of the path is writable by a non-root user.
        '';

        type = types.bool;
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Extra lines to be added verbatim to the configuration file.
        '';

        type = types.lines;
      };

      extraGlobalDefs = mkOption {
        default = "";

        description = ''
          Extra lines to be added verbatim to the 'global_defs' block of the
          configuration file
        '';

        type = types.lines;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to automatically allow VRRP and AH packets in the firewall.
        '';

        type = types.bool;
      };

      secretFile = mkOption {
        default = null;

        description = ''
          Environment variables from this file will be interpolated into the
          final config file using envsubst with this syntax: `$ENVIRONMENT`
          or `''${VARIABLE}`.
          The file should contain lines formatted as `SECRET_VAR=SECRET_VALUE`.
          This is useful to avoid putting secrets into the nix store.
        '';

        example = "/run/keys/keepalived.env";
        type = types.nullOr types.path;
      };

      snmp = {

        enable = mkOption {
          default = false;

          description = ''
            Whether to enable the builtin AgentX subagent.
          '';

          type = types.bool;
        };

        enableChecker = mkOption {
          default = false;

          description = ''
            Enable SNMP handling of checker element of KEEPALIVED MIB.
          '';

          type = types.bool;
        };

        enableKeepalived = mkOption {
          default = false;

          description = ''
            Enable SNMP handling of vrrp element of KEEPALIVED MIB.
          '';

          type = types.bool;
        };

        enableRfc = mkOption {
          default = false;

          description = ''
            Enable SNMP handling of RFC2787 and RFC6527 VRRP MIBs.
          '';

          type = types.bool;
        };

        enableRfcV2 = mkOption {
          default = false;

          description = ''
            Enable SNMP handling of RFC2787 VRRP MIB.
          '';

          type = types.bool;
        };

        enableRfcV3 = mkOption {
          default = false;

          description = ''
            Enable SNMP handling of RFC6527 VRRP MIB.
          '';

          type = types.bool;
        };

        enableTraps = mkOption {
          default = false;

          description = ''
            Enable SNMP traps.
          '';

          type = types.bool;
        };

        socket = mkOption {
          default = null;

          description = ''
            Socket to use for connecting to SNMP master agent. If this value is
            set to null, keepalived's default will be used, which is
            unix:/var/agentx/master, unless using a network namespace, when the
            default is udp:localhost:705.
          '';

          type = types.nullOr types.str;
        };

      };

      vrrpInstances = mkOption {
        default = { };
        description = "Declarative vhost config";

        type = types.attrsOf (
          types.submodule (
            import ./vrrp-instance-options.nix {
              inherit lib;
            }
          )
        );
      };

      vrrpScripts = mkOption {
        default = { };
        description = "Declarative vrrp script config";

        type = types.attrsOf (
          types.submodule (
            import ./vrrp-script-options.nix {
              inherit lib;
            }
          )
        );
      };

    };
  };

  config = mkIf cfg.enable {

    assertions = flatten (map vrrpInstanceAssertions vrrpInstances);

    networking.firewall = lib.mkIf cfg.openFirewall (
      if config.networking.nftables.enable then
        {
          extraInputRules = ''
            meta l4proto vrrp counter accept comment "services.keepalived.openFirewall"
            meta l4proto ah counter accept comment "services.keepalived.openFirewall"
          '';
        }
      else
        {
          extraCommands = ''
            # Allow VRRP and AH packets
            ip46tables -A nixos-fw -p vrrp -m comment --comment "services.keepalived.openFirewall" -j ACCEPT
            ip46tables -A nixos-fw -p ah -m comment --comment "services.keepalived.openFirewall" -j ACCEPT
          '';

          extraStopCommands = ''
            ip46tables -D nixos-fw -p vrrp -m comment --comment "services.keepalived.openFirewall" -j ACCEPT
            ip46tables -D nixos-fw -p ah -m comment --comment "services.keepalived.openFirewall" -j ACCEPT
          '';
        }
    );

    systemd.services.keepalived =
      let
        finalConfigFile =
          if cfg.secretFile == null then keepalivedConf else "/run/keepalived/keepalived.conf";
      in
      {
        after = [
          "network.target"
          "network-online.target"
        ];

        description = "Keepalive Daemon (LVS and VRRP)";

        serviceConfig = {
          EnvironmentFile = lib.optional (cfg.secretFile != null) cfg.secretFile;
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

          ExecStart =
            "${lib.getExe cfg.package}"
            + " -f ${finalConfigFile}"
            + " -p ${pidFile}"
            + optionalString cfg.snmp.enable " --snmp";

          ExecStartPre = lib.optional (cfg.secretFile != null) (
            pkgs.writeShellScript "keepalived-pre-start" ''
              umask 077
              ${pkgs.envsubst}/bin/envsubst -i "${keepalivedConf}" > ${finalConfigFile}
            ''
          );

          KillMode = "process";
          PIDFile = pidFile;
          Restart = "always";
          RestartSec = "1s";
          RuntimeDirectory = "keepalived";
          Type = "forking";
        };

        wants = [ "network-online.target" ];
      };

    systemd.timers.keepalived-boot-delay = {
      after = [
        "network.target"
        "network-online.target"
      ];

      description = "Keepalive Daemon delay to avoid instant transition to MASTER state";
      requires = [ "network-online.target" ];

      timerConfig = {
        OnActiveSec = "5s";
        Unit = "keepalived.service";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.raitobezarius ];
}
