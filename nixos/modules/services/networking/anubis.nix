{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  jsonFormat = pkgs.formats.json { };

  cfg = config.services.anubis;
  enabledInstances = lib.filterAttrs (_: conf: conf.enable) cfg.instances;
  instanceName = name: if name == "" then "anubis" else "anubis-${name}";

  # Only generates a custom policy file when the user has explicitly customized
  # something (extraBots, settings, or disabled default bot rules). When nothing
  # is customized, returns null so Anubis uses its built-in botPolicies.yaml
  # which includes sensible defaults for thresholds, status_codes, store, etc.
  mkPolicyFile =
    name: instance:
    let
      hasCustomization =
        !instance.policy.useDefaultBotRules
        || instance.policy.extraBots != [ ]
        || instance.policy.settings != { };
      bots =
        (lib.optional instance.policy.useDefaultBotRules {
          import = "(data)/meta/default-config.yaml";
        })
        ++ instance.policy.extraBots;
      policyContent = {
        inherit bots;
      }
      // instance.policy.settings;
    in
    if hasCustomization then
      jsonFormat.generate "${instanceName name}-policy.json" policyContent
    else
      null;

  unixAddr = network: addr: lib.strings.optionalString (network == "unix") addr;
  unixSocketAddrs =
    settings:
    lib.filter (x: x != "") [
      (unixAddr settings.BIND_NETWORK settings.BIND)
      (unixAddr settings.METRICS_BIND_NETWORK settings.METRICS_BIND)
    ];
  instanceUsesUnixSockets = instance: lib.length (unixSocketAddrs instance.settings) > 0;
  runtimeDirectoryPrefix = name: "/run/anubis/${instanceName name}/";

  commonSubmodule =
    isDefault:
    let
      mkDefaultOption =
        path: opts:
        lib.mkOption (
          opts
          // lib.optionalAttrs (!isDefault && opts ? default) {
            default =
              lib.attrByPath (lib.splitString "." path)
                (throw "This is a bug in the Anubis module. Please report this as an issue.")
                cfg.defaultOptions;

            defaultText = lib.literalExpression "config.services.anubis.defaultOptions.${path}";
          }
        );
    in
    { name, ... }:
    {
      imports = [
        (lib.mkRenamedOptionModule [ "botPolicy" ] [ "policy" "settings" ])
      ];

      options = {
        enable = lib.mkEnableOption "this instance of Anubis" // {
          default = true;
        };

        extraFlags = mkDefaultOption "extraFlags" {
          default = [ ];
          description = "A list of extra flags to be passed to Anubis.";
          example = [ "-metrics-bind \"\"" ];
          type = types.listOf types.str;
        };

        group = mkDefaultOption "group" {
          default = "anubis";

          description = ''
            The group under which Anubis is run.

            This module utilizes systemd's DynamicUser feature. See the corresponding section in
            {manpage}`systemd.exec(5)` for more details.
          '';

          type = types.str;
        };

        policy = lib.mkOption {
          default = { };

          description = ''
            Anubis policy configuration.

            See [the documentation](https://anubis.techaro.lol/docs/admin/policies) for details.
          '';

          type = types.submodule {
            options = {
              extraBots = mkDefaultOption "policy.extraBots" {
                default = [ ];

                description = ''
                  Additional bot rules appended to the policy.

                  When {option}`useDefaultBotRules` is `true`, these rules are added after
                  Anubis's default rules. When `false`, only these rules are used.
                '';

                example = lib.literalExpression ''
                  [
                    {
                      name = "my-bot";
                      user_agent_regex = "MyBot/.*";
                      action = "ALLOW";
                    }
                  ]
                '';

                type = types.listOf jsonFormat.type;
              };

              settings = mkDefaultOption "policy.settings" {
                default = { };

                description = ''
                  Additional policy settings merged into the policy file.

                  Common settings include `dnsbl`, `store`, `logging`, `thresholds`,
                  `impressum`, `openGraph`, and `statusCodes`.

                  See [the documentation](https://anubis.techaro.lol/docs/admin/policies) for
                  available options.
                '';

                example = lib.literalExpression ''
                  {
                    dnsbl = false;
                    store = {
                      backend = "bbolt";
                      parameters.path = "/var/lib/anubis/data.bdb";
                    };
                  }
                '';

                type = jsonFormat.type;
              };

              useDefaultBotRules = mkDefaultOption "policy.useDefaultBotRules" {
                default = true;

                description = ''
                  Whether to include Anubis's default bot detection rules via the
                  `(data)/meta/default-config.yaml` import.

                  Set to `false` to define your own bot rules from scratch using
                  {option}`extraBots`.
                '';

                type = types.bool;
              };
            };
          };
        };

        settings = lib.mkOption {
          default = { };

          description = ''
            Freeform configuration via environment variables for Anubis.

            See [the documentation](https://anubis.techaro.lol/docs/admin/installation) for a complete list of
            available environment variables.
          '';

          type = types.submodule [
            {
              options = {
                # BIND and METRICS_BIND are defined in instance specific options, since global defaults don't make sense
                BIND_NETWORK = mkDefaultOption "settings.BIND_NETWORK" {
                  default = "unix";

                  description = ''
                    The network family that Anubis should bind to.

                    Accepts anything supported by Go's [`net.Listen`](https://pkg.go.dev/net#Listen).

                    Common values are `tcp` and `unix`.
                  '';

                  example = "tcp";
                  type = types.str;
                };

                DIFFICULTY = mkDefaultOption "settings.DIFFICULTY" {
                  default = 4;

                  description = ''
                    The difficulty required for clients to solve the challenge.

                    Currently, this means the amount of leading zeros in a successful response.
                  '';

                  example = 5;
                  type = types.int;
                };

                METRICS_BIND_NETWORK = mkDefaultOption "settings.METRICS_BIND_NETWORK" {
                  default = "unix";

                  description = ''
                    The network family that the metrics server should bind to.

                    Accepts anything supported by Go's [`net.Listen`](https://pkg.go.dev/net#Listen).

                    Common values are `tcp` and `unix`.
                  '';

                  example = "tcp";
                  type = types.str;
                };

                OG_PASSTHROUGH = mkDefaultOption "settings.OG_PASSTHROUGH" {
                  default = false;

                  description = ''
                    Whether to enable Open Graph tag passthrough.

                    This enables social previews of resources protected by
                    Anubis without having to exempt each scraper individually.
                  '';

                  type = types.bool;
                };

                # generated by default
                POLICY_FNAME = mkDefaultOption "settings.POLICY_FNAME" {
                  default = null;

                  description = ''
                    The policy file to use. Leave this as `null` to use the policy generated from
                    {option}`services.anubis.instances.<name>.policy`.
                  '';

                  type = types.nullOr types.path;
                };

                SERVE_ROBOTS_TXT = mkDefaultOption "settings.SERVE_ROBOTS_TXT" {
                  default = false;

                  description = ''
                    Whether to serve a default robots.txt that denies access to common AI bots by name and all other
                    bots by wildcard.
                  '';

                  type = types.bool;
                };

                WEBMASTER_EMAIL = mkDefaultOption "settings.WEBMASTER_EMAIL" {
                  default = null;

                  description = ''
                    If set, shows a contact email address when rendering error pages.

                    This email address will be how users can get in contact with administrators.
                  '';

                  example = "alice@example.com";
                  type = types.nullOr types.str;
                };
              };

              freeformType =
                with types;
                attrsOf (
                  nullOr (oneOf [
                    str
                    int
                    bool
                  ])
                );
            }
            (lib.optionalAttrs (!isDefault) (instanceSpecificOptions name))
          ];
        };

        user = mkDefaultOption "user" {
          default = "anubis";

          description = ''
            The user under which Anubis is run.

            This module utilizes systemd's DynamicUser feature. See the corresponding section in
            {manpage}`systemd.exec(5)` for more details.
          '';

          type = types.str;
        };
      };
    };

  instanceSpecificOptions = name: {
    options = {
      # see other options above
      BIND = lib.mkOption {
        default = "${runtimeDirectoryPrefix name}anubis.sock";

        description = ''
          The address that Anubis listens to. See Go's [`net.Listen`](https://pkg.go.dev/net#Listen) for syntax.
          When using unix sockets:
          - use the prefix "${runtimeDirectoryPrefix ""}" if the instance name is the empty string,
          - "${runtimeDirectoryPrefix "<name>"}" otherwise.

          Defaults to Unix domain sockets. To use TCP sockets, set this to a TCP address and `BIND_NETWORK` to `"tcp"`.
        '';

        example = ":8080";
        type = types.str;
      };

      METRICS_BIND = lib.mkOption {
        default = "${runtimeDirectoryPrefix name}anubis-metrics.sock";

        description = ''
          The address Anubis' metrics server listens to. See Go's [`net.Listen`](https://pkg.go.dev/net#Listen) for
          syntax.
          When using unix sockets:
          - use the prefix "${runtimeDirectoryPrefix ""}" if the instance name is the empty string,
          - "${runtimeDirectoryPrefix "<name>"}" otherwise.

          The metrics server is enabled by default and may be disabled. However, due to implementation details, this is
          only possible by setting a command line flag. See {option}`services.anubis.defaultOptions.extraFlags` for an
          example.

          Defaults to Unix domain sockets. To use TCP sockets, set this to a TCP address and `METRICS_BIND_NETWORK` to
          `"tcp"`.
        '';

        example = "127.0.0.1:8081";
        type = types.str;
      };

      TARGET = lib.mkOption {
        description = ''
          The reverse proxy target that Anubis is protecting. This is a required option.

          The usage of Unix domain sockets is supported by the following syntax: `unix:///path/to/socket.sock`.
        '';

        example = "http://127.0.0.1:8000";
        type = types.str;
      };
    };
  };
in
{
  options.services.anubis = {
    package = lib.mkPackageOption pkgs "anubis" { };

    defaultOptions = lib.mkOption {
      default = { };
      description = "Default options for all instances of Anubis.";
      type = types.submodule (commonSubmodule true);
    };

    instances = lib.mkOption {
      # Merge defaultOptions into each instance
      apply = lib.mapAttrs (_: lib.recursiveUpdate cfg.defaultOptions);
      default = { };

      description = ''
        An attribute set of Anubis instances.

        The attribute name may be an empty string, in which case the `-<name>` suffix is not added to the service name
        and socket paths.
      '';

      type = types.attrsOf (types.submodule (commonSubmodule false));
    };
  };

  config = lib.mkIf (enabledInstances != { }) {
    assertions =
      let
        validInstanceUnixSocketAddrs =
          name: instance:
          lib.all (lib.hasPrefix (runtimeDirectoryPrefix name)) (unixSocketAddrs instance.settings);
      in
      [
        {
          assertion = lib.all (attrs: validInstanceUnixSocketAddrs attrs.name attrs.value) (
            lib.attrsToList enabledInstances
          );

          message = ''
            When using unix sockets in services.anubis.instances.<name>.settings.BIND and services.anubis.instances.<name>.settings.METRICS_BIND:
              - use the prefix "${runtimeDirectoryPrefix ""}" if the instance name is the empty string,
              - "${runtimeDirectoryPrefix "<name>"}" otherwise.
          '';
        }
      ];

    systemd.services = lib.mapAttrs' (
      name: instance:
      lib.nameValuePair "${instanceName name}" {
        after = [ "network-online.target" ];
        description = "Anubis (${if name == "" then "default" else name} instance)";

        environment = lib.mapAttrs (lib.const (lib.generators.mkValueStringDefault { })) (
          lib.filterAttrs (_: v: v != null) (
            instance.settings
            // {
              POLICY_FNAME =
                if instance.settings.POLICY_FNAME != null then
                  instance.settings.POLICY_FNAME
                else
                  mkPolicyFile name instance;
            }
          )
        );

        serviceConfig = {
          AmbientCapabilities = "";
          CapabilityBoundingSet = null;
          DynamicUser = true;

          ExecStart = lib.concatStringsSep " " (
            (lib.singleton (lib.getExe cfg.package)) ++ instance.extraFlags
          );

          Group = instance.group;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          # hardening
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = "strict";
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = if instanceUsesUnixSockets instance then "anubis/${instanceName name}" else null;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          User = instance.user;
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      }
    ) enabledInstances;

    users.groups = lib.mkIf (cfg.defaultOptions.group == "anubis") {
      anubis = { };
    };

    users.users = lib.mkIf (cfg.defaultOptions.user == "anubis") {
      anubis = {
        group = cfg.defaultOptions.group;
        isSystemUser = true;
      };
    };
  };

  meta.doc = ./anubis.md;

  meta.maintainers = with lib.maintainers; [
    soopyc
    nullcube
  ];
}
