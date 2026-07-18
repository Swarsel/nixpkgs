{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tts;
in

{
  options.services.tts =
    let
      inherit (lib)
        literalExpression
        mkOption
        mkEnableOption
        types
        ;
    in
    {
      servers = mkOption {
        default = { };

        description = ''
          TTS server instances.
        '';

        example = literalExpression ''
          {
            english = {
              port = 5300;
              model = "tts_models/en/ljspeech/tacotron2-DDC";
            };
            german = {
              port = 5301;
              model = "tts_models/de/thorsten/tacotron2-DDC";
            };
            dutch = {
              port = 5302;
              model = "tts_models/nl/mai/tacotron2-DDC";
            };
          }
        '';

        type = types.attrsOf (
          types.submodule (
            { ... }:
            {
              options = {
                enable = mkEnableOption "Coqui TTS server";

                extraArgs = mkOption {
                  default = [ ];

                  description = ''
                    Extra arguments to pass to the server commandline.
                  '';

                  type = types.listOf types.str;
                };

                model = mkOption {
                  default = "tts_models/en/ljspeech/tacotron2-DDC";

                  description = ''
                    Name of the model to download and use for speech synthesis.

                    Check `tts-server --list_models` for possible values.

                    Set to `null` to use a custom model.
                  '';

                  example = null;
                  type = types.nullOr types.str;
                };

                port = mkOption {
                  description = ''
                    Port to bind the TTS server to.
                  '';

                  example = 5000;
                  type = types.port;
                };

                useCuda = mkOption {
                  default = false;

                  description = ''
                    Whether to offload computation onto a CUDA compatible GPU.
                  '';

                  example = true;
                  type = types.bool;
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
        mkIf
        mapAttrs'
        nameValuePair
        optionalString
        escapeShellArgs
        ;
    in
    mkIf (cfg.servers != { }) {
      systemd.services = mapAttrs' (
        server: options:
        nameValuePair "tts-${server}" {
          after = [
            "network-online.target"
          ];

          description = "Coqui TTS server instance ${server}";
          environment.HOME = "/var/lib/tts";

          path = with pkgs; [
            espeak-ng
          ];

          serviceConfig = {
            CapabilityBoundingSet = "";

            DeviceAllow =
              if options.useCuda then
                [
                  # https://docs.nvidia.com/dgx/pdf/dgx-os-5-user-guide.pdf
                  "/dev/nvidia1"
                  "/dev/nvidia2"
                  "/dev/nvidia3"
                  "/dev/nvidia4"
                  "/dev/nvidia-caps/nvidia-cap1"
                  "/dev/nvidia-caps/nvidia-cap2"
                  "/dev/nvidiactl"
                  "/dev/nvidia-modeset"
                  "/dev/nvidia-uvm"
                  "/dev/nvidia-uvm-tools"
                ]
              else
                "";

            DevicePolicy = "closed";
            DynamicUser = true;

            ExecStart =
              "${pkgs.tts}/bin/tts-server --port ${toString options.port} "
              + optionalString (options.model != null) "--model_name ${options.model} "
              + optionalString (options.useCuda) "--use_cuda "
              + (escapeShellArgs options.extraArgs);

            LockPersonality = true;
            # jit via numba->llvmpipe
            MemoryDenyWriteExecute = false;
            PrivateDevices = true;
            PrivateUsers = true;
            ProcSubset = "pid";
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";

            RestrictAddressFamilies = [
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
            ];

            RestrictNamespaces = true;
            RestrictRealtime = true;
            StateDirectory = "tts";
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              "@system-service"
              "~@privileged"
            ];

            UMask = "0077";
            User = "tts";
          };

          wantedBy = [
            "multi-user.target"
          ];
        }
      ) cfg.servers;
    };
}
