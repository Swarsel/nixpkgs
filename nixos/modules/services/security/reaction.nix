{
  config,
  lib,
  pkgs,
  ...
}:
let
  settingsFormat = pkgs.formats.yaml { };

  cfg = config.services.reaction;

  inherit (lib)
    concatMapStringsSep
    filterAttrs
    getExe
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    mapAttrs
    optional
    optionals
    optionalString
    types
    ;
in
{
  options.services.reaction = {
    enable = mkEnableOption "enable reaction";
    package = mkPackageOption pkgs "reaction" { };

    checkConfig = mkOption {
      default = true;
      description = "Check the syntax of the configuration files at build time";
      type = types.bool;
    };

    loglevel = mkOption {
      default = null;

      description = ''
        reaction's loglevel. One of DEBUG, INFO, WARN, ERROR.
      '';

      type = types.nullOr (
        types.enum [
          "DEBUG"
          "INFO"
          "WARN"
          "ERROR"
        ]
      );
    };

    runAsRoot = mkOption {
      default = false;

      description = ''
        Whether to run reaction as root.
        Defaults to false, where an unprivileged reaction user is created.

        Be sure to give it sufficient permissions.
        Example config permitting `iptables` and `journalctl` use

        ```nix
        {
          # allows reading journal logs of processess
          users.users.reaction.extraGroups = [ "systemd-journal" ];

          # allows modifying ip firewall rules
          systemd.services.reaction.unitConfig.ConditionCapability = "CAP_NET_ADMIN";
          systemd.services.reaction.serviceConfig = {
            CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
            AmbientCapabilities = [ "CAP_NET_ADMIN" ];
          };

          # optional, if more control over ssh logs is needed
          services.openssh.settings.LogLevel = lib.mkDefault "VERBOSE";
        }
        ```

        ```nix
        # core ipset plugin requires these if running as non-root
        systemd.services.reaction.serviceConfig = {
          CapabilityBoundingSet = [
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
            "CAP_DAC_READ_SEARCH" # for journalctl
          ];
          AmbientCapabilities = [
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
            "CAP_DAC_READ_SEARCH"
          ];
        };
        ```
      '';

      type = types.bool;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for reaction. See the [wiki](https://framagit.org/ppom/reaction-wiki).

        The settings are written as a YAML file.

        Can be used in combination with `settingsFiles` option, both will be present in the configuration directory.
      '';

      type = types.submodule {
        options = {
          plugins = mkOption {
            # Filter plugins which are disabled
            apply =
              self:
              lib.pipe self [
                (filterAttrs (name: p: p.enable))
                (mapAttrs (name: p: removeAttrs p [ "enable" ]))
              ];

            default = { };

            description = ''
              Nixpkgs provides a `reaction-plugins` package set which includes both offical and community plugins for reaction.

              To use the plugins in your module configuration, in `settings.plugins` you can use for e.g. `''${lib.getExe reaction-plugins.reaction-plugin-ipset}`
              See https://reaction.ppom.me/plugins/ to configure plugins.
            '';

            type = types.attrsOf (
              types.submodule (
                { name, ... }:
                {
                  options = {
                    enable = mkOption {
                      default = true;
                      description = "enable reaction-plugin-${name}";
                      type = types.bool;
                    };

                    check_root = mkOption {
                      default = true;
                      description = "Whether reaction must check that the executable is owned by root";
                      type = types.bool;
                    };

                    path = mkOption {
                      default = "${cfg.package.plugins."reaction-plugin-${name}"}/bin/reaction-plugin-${name}";
                      defaultText = lib.literalExpression ''''${cfg.package.plugins."reaction-plugin-${name}"}/bin/reaction-plugin-${name}'';
                      description = "path to the plugin binary";
                      type = types.str;
                    };

                    systemd = mkOption {
                      default = cfg.runAsRoot;
                      defaultText = "config.services.reaction.runAsRoot";
                      description = "Whether reaction must isolate the plugin using systemd's run0";
                      type = types.bool;
                    };

                    systemd_options = mkOption {
                      default = { };

                      description = ''
                        A key-value map of systemd options.
                        Keys must be strings and values must be string arrays.

                        See `man systemd.directives` for all supported options, and particularly options in `man systemd.exec`
                      '';

                      type = types.attrsOf (types.listOf types.str);
                    };
                  };
                }
              )
            );
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    settingsFiles = mkOption {
      default = [ ];

      description = ''
        Configuration for reaction, see the [wiki](https://framagit.org/ppom/reaction-wiki).

        reaction supports JSON, YAML and JSONnet. For those who prefer to take advantage of JSONnet rather than Nix.

        Can be used in combination with `settings` option, both will be present in the configuration directory.
      '';

      type = types.listOf types.path;
    };

    stopForFirewall = mkOption {
      default = false;

      description = ''
        Whether to stop reaction when reloading the firewall.

        The presence of a reaction chain in the INPUT table may cause the firewall
        reload to fail.
        One can alternatively cherry-pick the right iptables commands to execute before and after the firewall
        ```nix
        {
          systemd.services.firewall.serviceConfig = {
            ExecStopPre = [ "''${pkgs.iptables}/bin/iptables -w -D INPUT -p all -j reaction" ];
            ExecStartPost = [ "''${pkgs.iptables}/bin/iptables -w -I INPUT -p all -j reaction" ];
          };
        }
        ```
      '';

      type = types.bool;
    };
  };

  config =
    let
      generatedSettings = settingsFormat.generate "reaction.yml" cfg.settings;
      settingsDir = pkgs.runCommand "reaction-settings-dir" { } ''
        mkdir -p $out
        ${concatMapStringsSep "\n" (file: ''
          filename=$(basename "${file}")
          ln -s "${file}" "$out/$filename"
        '') cfg.settingsFiles}
        ln -s ${generatedSettings} $out/reaction.yml
      '';
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.settings != { } || (builtins.length cfg.settingsFiles) != 0;
          message = "You must specify settings and/or settingsFile options";
        }
      ];

      environment.systemPackages = [ cfg.package ];

      # pre-configure official plugins
      services.reaction.settings.plugins = {
        ipset = {
          enable = mkDefault true;

          systemd_options = {
            CapabilityBoundingSet = [
              "~CAP_NET_ADMIN"
              "~CAP_PERFMON"
            ];
          };
        };

        virtual.enable = mkDefault true;
      };

      system.checks =
        optional (cfg.checkConfig && pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform)
          (
            pkgs.runCommand "reaction-config-validation" { } ''
              ${getExe cfg.package} test-config -c ${settingsDir} >/dev/null
              echo "reaction config ${settingsDir} is valid"
              touch $out
            ''
          );

      systemd.services.reaction = {
        after = [ "network.target" ];
        description = "A daemon that scans program outputs for repeated patterns, and takes action.";
        documentation = [ "https://reaction.ppom.me" ];
        partOf = optionals cfg.stopForFirewall [ "firewall.service" ];
        path = [ pkgs.iptables ];

        serviceConfig = {
          ExecStart = ''
            ${getExe cfg.package} start -c ${settingsDir}${
              optionalString (cfg.loglevel != null) " -l ${cfg.loglevel}"
            }
          '';

          KillMode = "mixed"; # for plugins
          LogsDirectory = "reaction";
          LogsDirectoryMode = "0750";
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RemoveIPC = true;
          RuntimeDirectory = "reaction";
          RuntimeDirectoryMode = "0750";
          Slice = "system-reaction.slice";
          StateDirectory = "reaction";
          StateDirectoryMode = "0750";
          Type = "simple";
          UMask = 0077;
          User = if (!cfg.runAsRoot) then "reaction" else "root";
          WorkingDirectory = "%S/reaction";
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.slices.system-reaction = {
        description = "Reaction system slice";
      };

      users = mkIf (!cfg.runAsRoot) {
        groups.reaction = { };

        users.reaction = {
          group = "reaction";
          isSystemUser = true;
        };
      };
    };

  meta.maintainers = with lib.maintainers; [
    ppom
  ];

  meta.teams = [ lib.teams.ngi ];
}
