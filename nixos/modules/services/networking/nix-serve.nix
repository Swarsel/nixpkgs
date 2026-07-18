{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.nix-serve;
in
{
  options = {
    services.nix-serve = {
      enable = mkEnableOption "nix-serve, the standalone Nix binary cache server";
      package = mkPackageOption pkgs "nix-serve" { };

      bindAddress = mkOption {
        default = "0.0.0.0";

        description = ''
          IP address where nix-serve will bind its listening socket.
        '';

        type = types.str;
      };

      extraParams = mkOption {
        default = "";

        description = ''
          Extra command line parameters for nix-serve.
        '';

        type = types.separatedString " ";
      };

      openFirewall = mkOption {
        default = false;
        description = "Open ports in the firewall for nix-serve.";
        type = types.bool;
      };

      port = mkOption {
        default = 5000;

        description = ''
          Port number where nix-serve will listen on.
        '';

        type = types.port;
      };

      secretKeyFile = mkOption {
        default = null;

        description = ''
          The path to the file used for signing derivation data.
          Generate with:

          ```
          nix-store --generate-binary-cache-key key-name secret-key-file public-key-file
          ```

          For more details see {manpage}`nix-store(1)`.
        '';

        type = types.nullOr types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    nix.settings = lib.optionalAttrs (lib.versionAtLeast config.nix.package.version "2.4") {
      extra-allowed-users = [ "nix-serve" ];
    };

    systemd.services.nix-serve = {
      after = [ "network.target" ];
      description = "nix-serve binary cache server";
      environment.NIX_REMOTE = "daemon";

      path = [
        config.nix.package.out
        pkgs.bzip2.bin
      ];

      script = ''
        ${lib.optionalString (cfg.secretKeyFile != null) ''
          export NIX_SECRET_KEY_FILE="$CREDENTIALS_DIRECTORY/NIX_SECRET_KEY_FILE"
        ''}
        exec ${cfg.package}/bin/nix-serve --listen ${cfg.bindAddress}:${toString cfg.port} ${cfg.extraParams}
      '';

      serviceConfig = {
        DynamicUser = true;
        Group = "nix-serve";

        LoadCredential = lib.optionalString (
          cfg.secretKeyFile != null
        ) "NIX_SECRET_KEY_FILE:${cfg.secretKeyFile}";

        Restart = "always";
        RestartSec = "5s";
        User = "nix-serve";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
