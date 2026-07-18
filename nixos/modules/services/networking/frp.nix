{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.frp;
  settingsFormat = pkgs.formats.toml { };
  enabledInstances = lib.filterAttrs (name: conf: conf.enable) cfg.instances;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "frp" "enable" ]
      [ "services" "frp" "instances" "" "enable" ]
    )
    (lib.mkRenamedOptionModule [ "services" "frp" "role" ] [ "services" "frp" "instances" "" "role" ])
    (lib.mkRenamedOptionModule
      [ "services" "frp" "settings" ]
      [ "services" "frp" "instances" "" "settings" ]
    )
  ];

  options = {
    services.frp = {
      package = lib.mkPackageOption pkgs "frp" { };

      instances = lib.mkOption {
        default = { };

        description = ''
          Frp instances.
        '';

        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              enable = lib.mkEnableOption "frp";

              environmentFiles = lib.mkOption {
                default = [ ];

                description = ''
                  List of paths files that follows systemd environmentfile structure.
                  Can be used to pass secrets to settings attribute.

                  Example content of a file: SECRET_TOKEN=1234
                '';

                type = lib.types.listOf lib.types.path;
              };

              extraConfig = lib.mkOption {
                default = "";

                description = ''
                  Extra frp TOML configuration included at the end of the generated configuration file.
                  Especially useful for [port range mapping].

                  [port range mapping]: https://github.com/fatedier/frp#port-range-mapping
                '';

                example = ''
                  {{- range $_, $v := parseNumberRangePair "6000-6006,6007" "6000-6006,6007" }}
                  [[proxies]]
                  name = "tcp-{{ $v.First }}"
                  type = "tcp"
                  localPort = {{ $v.First }}
                  remotePort = {{ $v.Second }}
                  {{- end }}
                '';

                type = lib.types.lines;
              };

              role = lib.mkOption {
                description = ''
                  The frp consists of `client` and `server`. The server is usually
                  deployed on the machine with a public IP address, and
                  the client is usually deployed on the machine
                  where the Intranet service to be penetrated resides.
                '';

                type = lib.types.enum [
                  "server"
                  "client"
                ];
              };

              settings = lib.mkOption {
                default = { };

                description = ''
                  Frp configuration, for configuration options
                  see the example of [client](https://github.com/fatedier/frp/blob/dev/conf/frpc_full_example.toml)
                  or [server](https://github.com/fatedier/frp/blob/dev/conf/frps_full_example.toml) on github.
                '';

                example = {
                  proxies = [
                    {
                      localIP = "127.0.0.1";
                      localPort = 22;
                      name = "ssh";
                      remotePort = 6000;
                      type = "tcp";
                    }
                  ];

                  serverAddr = "x.x.x.x";
                  serverPort = 7000;
                };

                type = settingsFormat.type;
              };
            };
          }
        );
      };
    };
  };

  config = lib.mkIf (enabledInstances != { }) {
    systemd.services = lib.mapAttrs' (
      instance: options:
      let
        serviceName = "frp" + lib.optionalString (instance != "") ("-" + instance);
        baseConfigFile = settingsFormat.generate "${serviceName}-base.toml" options.settings;
        configFile =
          if options.extraConfig == "" then
            baseConfigFile
          else
            pkgs.writeText "${serviceName}.toml" ''
              # Nixos Module settings
              ${builtins.readFile baseConfigFile}

              # Nixos Module extraConfig
              ${options.extraConfig}
            '';
        isClient = (options.role == "client");
        isServer = (options.role == "server");
        serviceCapability = lib.optionals isServer [ "CAP_NET_BIND_SERVICE" ];
        executableFile = if isClient then "frpc" else "frps";
      in
      lib.nameValuePair serviceName {
        after = if isClient then [ "network-online.target" ] else [ "network.target" ];
        description = "A fast reverse proxy frp ${options.role} for instance ${instance}";

        serviceConfig = {
          AmbientCapabilities = serviceCapability;
          # Hardening
          CapabilityBoundingSet = serviceCapability;
          DynamicUser = true;
          EnvironmentFile = options.environmentFiles;
          ExecStart = "${cfg.package}/bin/${executableFile} --strict_config -c ${configFile}";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateMounts = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          Restart = "on-failure";
          RestartSec = 15;

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ]
          ++ lib.optionals isClient [ "AF_UNIX" ];

          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "@system-service" ];
          Type = "simple";
        }
        // lib.optionalAttrs isServer {
          StateDirectory = "frp";
          StateDirectoryMode = "0700";
          UMask = "0007";
        };

        wantedBy = [ "multi-user.target" ];
        wants = lib.optionals isClient [ "network-online.target" ];
      }
    ) enabledInstances;
  };

  meta.maintainers = with lib.maintainers; [
    zaldnoay
    epireyn
  ];
}
