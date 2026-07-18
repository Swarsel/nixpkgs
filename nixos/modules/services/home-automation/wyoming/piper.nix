{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.wyoming.piper;

  inherit (lib)
    literalExpression
    mkOption
    mkEnableOption
    mkPackageOption
    types
    ;

  inherit (builtins)
    toString
    ;

  inherit (utils)
    escapeSystemdExecArgs
    ;
in

{
  options.services.wyoming.piper = with types; {
    package = mkPackageOption pkgs "wyoming-piper" { };

    servers = mkOption {
      default = { };

      description = ''
        Attribute set of wyoming-piper instances to spawn.
      '';

      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = mkEnableOption "Wyoming Piper server";

              extraArgs = mkOption {
                default = [ ];

                description = ''
                  Extra arguments to pass to the server commandline.
                '';

                type = listOf str;
              };

              lengthScale = mkOption {
                apply = toString;
                default = 1.0;

                description = ''
                  Phoneme length value.
                '';

                type = float;
              };

              noiseScale = mkOption {
                apply = toString;
                default = 0.667;

                description = ''
                  Generator noise value.
                '';

                type = float;
              };

              noiseWidth = mkOption {
                apply = toString;
                default = 0.333;

                description = ''
                  Phoneme width noise value.
                '';

                type = float;
              };

              speaker = mkOption {
                apply = toString;
                default = 0;

                description = ''
                  ID of a specific speaker in a multi-speaker model.
                '';

                type = ints.unsigned;
              };

              uri = mkOption {
                description = ''
                  URI to bind the wyoming server to.
                '';

                example = "tcp://0.0.0.0:10200";
                type = strMatching "^(tcp|unix)://.*$";
              };

              useCUDA = mkOption {
                default = pkgs.config.cudaSupport;
                defaultText = literalExpression "pkgs.config.cudaSupport";

                description = ''
                  Whether to accelerate the underlying onnxruntime library with CUDA.
                '';

                type = bool;
              };

              voice = mkOption {
                description = ''
                  Name of the voice model to use. See the following website for samples:
                  https://rhasspy.github.io/piper-samples/
                '';

                example = "en-us-ryan-medium";
                type = str;
              };

              zeroconf = {
                enable = mkEnableOption "zeroconf discovery" // {
                  default = true;
                };

                name = mkOption {
                  default = "piper-${name}";

                  description = ''
                    The advertised name for zeroconf discovery.
                  '';

                  type = str;
                };
              };
            };
          }
        )
      );
    };
  };

  config =
    let
      inherit (lib)
        mapAttrs'
        mkIf
        nameValuePair
        ;
    in
    mkIf (cfg.servers != { }) {
      systemd.services = mapAttrs' (
        server: options:
        nameValuePair "wyoming-piper-${server}" {
          inherit (options) enable;

          after = [
            "network-online.target"
          ];

          description = "Wyoming Piper server instance ${server}";

          serviceConfig = {
            CapabilityBoundingSet = "";
            DeviceAllow = "";
            DevicePolicy = "closed";
            DynamicUser = true;

            # https://github.com/home-assistant/addons/blob/master/piper/rootfs/etc/s6-overlay/s6-rc.d/piper/run
            ExecStart = escapeSystemdExecArgs (
              [
                (lib.getExe cfg.package)
                "--data-dir"
                "/var/lib/wyoming/piper"
                "--uri"
                options.uri
                "--voice"
                options.voice
                "--speaker"
                options.speaker
                "--length-scale"
                options.lengthScale
                "--noise-scale"
                options.noiseScale
                "--noise-w-scale"
                options.noiseWidth
              ]
              ++ lib.optionals options.zeroconf.enable [
                "--zeroconf"
                options.zeroconf.name
              ]
              ++ lib.optionals options.useCUDA [
                "--use-cuda"
              ]
              ++ options.extraArgs
            );

            LockPersonality = true;
            MemoryDenyWriteExecute = false; # required for onnxruntime
            PrivateDevices = true;
            PrivateUsers = true;
            ProcSubset = "all"; # for onnxruntime, which queries cpuinfo
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";

            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ]
            ++ lib.optionals options.zeroconf.enable [
              # Zeroconf support require network interface enumeration
              "AF_NETLINK"
            ];

            RestrictNamespaces = true;
            RestrictRealtime = true;
            StateDirectory = [ "wyoming/piper" ];
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              "@system-service"
              "~@privileged"
            ];

            UMask = "0077";
            User = "wyoming-piper";
          };

          wantedBy = [
            "multi-user.target"
          ];

          wants = [
            "network-online.target"
          ];
        }
      ) cfg.servers;
    };
}
