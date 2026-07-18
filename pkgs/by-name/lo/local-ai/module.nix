{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.local-ai;
  inherit (lib) mkOption types;
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.local-ai = {
      environment.LLAMACPP_PARALLEL = toString cfg.parallelRequests;

      serviceConfig = {
        DynamicUser = true;

        ExecStart = lib.escapeShellArgs (
          [
            "${cfg.package}/bin/local-ai"
            "--address=:${toString cfg.port}"
            "--threads=${toString cfg.threads}"
            "--localai-config-dir=."
            "--models-path=${cfg.models}"
            "--log-level=${cfg.logLevel}"
          ]
          ++ lib.optional (cfg.parallelRequests > 1) "--parallel-requests"
          ++ cfg.extraArgs
        );

        RuntimeDirectory = "local-ai";
        WorkingDirectory = "%t/local-ai";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  options.services.local-ai = {
    enable = lib.mkEnableOption "Enable service";

    extraArgs = mkOption {
      default = [ ];
      type = types.listOf types.str;
    };

    logLevel = mkOption {
      default = "warn";

      type = types.enum [
        "error"
        "warn"
        "info"
        "debug"
        "trace"
      ];
    };

    models = mkOption {
      default = "models";
      type = types.either types.package types.str;
    };

    package = lib.mkPackageOption pkgs "local-ai" { };

    parallelRequests = mkOption {
      default = 1;
      type = types.int;
    };

    port = mkOption {
      default = 8080;
      type = types.port;
    };

    threads = mkOption {
      default = 1;
      type = types.int;
    };
  };
}
