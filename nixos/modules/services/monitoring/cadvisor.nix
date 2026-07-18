{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cadvisor;

in
{
  options = {
    services.cadvisor = {
      enable = lib.mkEnableOption "Cadvisor service";

      extraOptions = lib.mkOption {
        default = [ ];

        description = ''
          Additional cadvisor options.

          See <https://github.com/google/cadvisor/blob/master/docs/runtime_options.md> for available options.
        '';

        type = lib.types.listOf lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = "127.0.0.1";
        description = "Cadvisor listening host";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 8080;
        description = "Cadvisor listening port";
        type = lib.types.port;
      };

      storageDriver = lib.mkOption {
        default = null;
        description = "Cadvisor storage driver.";
        example = "influxdb";
        type = lib.types.nullOr lib.types.str;
      };

      storageDriverDb = lib.mkOption {
        default = "root";
        description = "Cadvisord storage driver database name.";
        type = lib.types.str;
      };

      storageDriverHost = lib.mkOption {
        default = "localhost:8086";
        description = "Cadvisor storage driver host.";
        type = lib.types.str;
      };

      storageDriverPassword = lib.mkOption {
        default = "root";

        description = ''
          Cadvisor storage driver password.

          Warning: this password is stored in the world-readable Nix store. It's
          recommended to use the {option}`storageDriverPasswordFile` option
          since that gives you control over the security of the password.
          {option}`storageDriverPasswordFile` also takes precedence over {option}`storageDriverPassword`.
        '';

        type = lib.types.str;
      };

      storageDriverPasswordFile = lib.mkOption {
        description = ''
          File that contains the cadvisor storage driver password.

          {option}`storageDriverPasswordFile` takes precedence over {option}`storageDriverPassword`

          Warning: when {option}`storageDriverPassword` is non-empty this defaults to a file in the
          world-readable Nix store that contains the value of {option}`storageDriverPassword`.

          It's recommended to override this with a path not in the Nix store.
          Tip: use [nixops key management](https://nixos.org/nixops/manual/#idm140737318306400)
        '';

        type = lib.types.str;
      };

      storageDriverSecure = lib.mkOption {
        default = false;
        description = "Cadvisor storage driver, enable secure communication.";
        type = lib.types.bool;
      };

      storageDriverUser = lib.mkOption {
        default = "root";
        description = "Cadvisor storage driver username.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkMerge [
    {
      services.cadvisor.storageDriverPasswordFile = lib.mkIf (cfg.storageDriverPassword != "") (
        lib.mkDefault (
          toString (
            pkgs.writeTextFile {
              name = "cadvisor-storage-driver-password";
              text = cfg.storageDriverPassword;
            }
          )
        )
      );
    }

    (lib.mkIf cfg.enable {
      systemd.services.cadvisor = {
        after = [
          "network.target"
          "docker.service"
          "influxdb.service"
        ];

        path = lib.optionals config.boot.zfs.enabled [ pkgs.zfs ];

        postStart = lib.mkBefore ''
          until ${pkgs.curl.bin}/bin/curl -s -o /dev/null 'http://${cfg.listenAddress}:${toString cfg.port}/containers/'; do
            sleep 1;
          done
        '';

        script = ''
          exec ${pkgs.cadvisor}/bin/cadvisor \
            -logtostderr=true \
            -listen_ip="${cfg.listenAddress}" \
            -port="${toString cfg.port}" \
            ${lib.escapeShellArgs cfg.extraOptions} \
            ${lib.optionalString (cfg.storageDriver != null) ''
              -storage_driver "${cfg.storageDriver}" \
              -storage_driver_host "${cfg.storageDriverHost}" \
              -storage_driver_db "${cfg.storageDriverDb}" \
              -storage_driver_user "${cfg.storageDriverUser}" \
              -storage_driver_password "$(cat "${cfg.storageDriverPasswordFile}")" \
              ${lib.optionalString cfg.storageDriverSecure "-storage_driver_secure"}
            ''}
        '';

        serviceConfig.TimeoutStartSec = 300;
        wantedBy = [ "multi-user.target" ];
      };
    })
  ];
}
