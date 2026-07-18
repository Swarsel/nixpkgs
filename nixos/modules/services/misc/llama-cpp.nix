{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.llama-cpp;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "llama-cpp" "host" ]
      [ "services" "llama-cpp" "settings" "host" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "llama-cpp" "port" ]
      [ "services" "llama-cpp" "settings" "port" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "llama-cpp" "model" ]
      [ "services" "llama-cpp" "settings" "model" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "llama-cpp" "modelsDir" ]
      [ "services" "llama-cpp" "settings" "models-dir" ]
    )
    (lib.mkRemovedOptionModule [ "services" "llama-cpp" "modelsPreset" ] ''
      Using a Nix attribute set for configuring model presets is no longer
      supported. However, it's possible to use
      `services.llama-cpp.settings.models-preset` to provide a path to an INI
      file with desired options.
    '')
    (lib.mkRemovedOptionModule [
      "services"
      "llama-cpp"
      "extraFlags"
    ] "Use `services.llama-cpp.settings` instead")
  ];

  options = {
    services.llama-cpp = {
      enable = lib.mkEnableOption "llama.cpp HTTP server";
      package = lib.mkPackageOption pkgs "llama-cpp" { };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the server.
        '';

        type = lib.types.bool;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Command-line arguments for `llama-server`.

          See <https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md>
          for the full list of options.
        '';

        example = {
          batch-size = 512;
          ctx-size = 252144;
          flash-attn = "on";
          host = "0.0.0.0";
          model = "/mnt/llms/Foo3.6-27B-UD-Q4_K_XL.gguf";
          port = 1337;
          spec-draft-n-max = 2;
          spec-type = "draft-mtp";
          temp = 0.6;
          top-k = 20;
          top-p = 0.95;
          ubatch-size = 256;
        };

        type = lib.types.submodule {
          options = {
            host = lib.mkOption {
              default = "127.0.0.1";

              description = ''
                IP address on which the server should listen on.
              '';

              example = "0.0.0.0";
              type = lib.types.str;
            };

            port = lib.mkOption {
              default = 8080;

              description = ''
                Port on which the server should listen on.
              '';

              example = 1337;
              type = lib.types.port;
            };
          };

          freeformType = lib.types.attrs;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.settings.port;

    systemd.services.llama-cpp = {
      after = [ "network.target" ];
      description = "llama.cpp HTTP server";

      serviceConfig = {
        AmbientCapabilities = [ "" ];
        CacheDirectory = "llama-cpp";
        CapabilityBoundingSet = [ "" ];
        DynamicUser = true;
        Environment = [ "LLAMA_CACHE=/var/cache/llama-cpp" ];
        ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -HUP $MAINPID";

        ExecStart = toString [
          (lib.getExe' cfg.package "llama-server")
          (lib.cli.toCommandLine (optionName: {
            explicitBool = false;
            formatArg = lib.generators.mkValueStringDefault { };
            option = if builtins.stringLength optionName > 1 then "--${optionName}" else "-${optionName}";
            sep = " ";
          }) cfg.settings)
        ];

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = false; # Required for GPU support.
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";
        RestartSec = 300;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "llama-cpp";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        WorkingDirectory = "/var/lib/llama-cpp";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    azahi
    newam
  ];
}
