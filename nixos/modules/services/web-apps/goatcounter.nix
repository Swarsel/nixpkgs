{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types;
  cfg = config.services.goatcounter;
  stateDir = "goatcounter";
in

{
  options = {
    services.goatcounter = {
      enable = lib.mkEnableOption "goatcounter";
      package = lib.mkPackageOption pkgs "goatcounter" { };

      address = lib.mkOption {
        default = "127.0.0.1";
        description = "Web interface address.";
        type = types.str;
      };

      extraArgs = lib.mkOption {
        default = [ ];

        description = ''
          List of extra arguments to be passed to goatcounter cli.
          See {command}`goatcounter help serve` for more information.
        '';

        type = with types; listOf str;
      };

      port = lib.mkOption {
        default = 8081;
        description = "Web interface port.";
        type = types.port;
      };

      proxy = lib.mkOption {
        default = false;

        description = ''
          Whether Goatcounter service is running behind a reverse proxy. Will listen for HTTPS if `false`.
          Refer to [documentation](https://github.com/arp242/goatcounter?tab=readme-ov-file#running) for more details.
        '';

        type = types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.goatcounter = {
      description = "Easy web analytics. No tracking of personal data.";

      serviceConfig = {
        DynamicUser = true;

        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "serve"
            "-listen"
            "${cfg.address}:${toString cfg.port}"
          ]
          ++ lib.optionals cfg.proxy [
            "-tls"
            "proxy"
          ]
          ++ cfg.extraArgs
        );

        Restart = "always";
        StateDirectory = stateDir;
        WorkingDirectory = "%S/${stateDir}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ bhankas ];
}
