{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  opts =
    { config, name, ... }:
    {
      options = {
        enable = mkOption {
          default = true;
          description = "Whether to enable proxy for this bucket";
          example = true;
          type = types.bool;
        };

        address = mkOption {
          description = "The address of the proxy.";
          example = "localhost:3000";
          type = types.str;
        };

        bucketName = mkOption {
          default = name;
          description = "Name of Google storage bucket";
          example = "my-bucket-name";
          type = types.str;
        };
      };
    };
  enabledProxies = lib.filterAttrs (n: v: v.enable) config.services.nix-store-gcs-proxy;
  mapProxies = function: lib.mkMerge (lib.mapAttrsToList function enabledProxies);
in
{
  options.services.nix-store-gcs-proxy = mkOption {
    default = { };

    description = ''
      An attribute set describing an HTTP to GCS proxy that allows us to use GCS
      bucket via HTTP protocol.
    '';

    type = types.attrsOf (types.submodule opts);
  };

  config.systemd.services = mapProxies (
    name: cfg: {
      "nix-store-gcs-proxy-${name}" = {
        description = "A HTTP nix store that proxies requests to Google Storage";

        serviceConfig = {
          DynamicUser = true;

          ExecStart = ''
            ${pkgs.nix-store-gcs-proxy}/bin/nix-store-gcs-proxy \
              --bucket-name ${cfg.bucketName} \
              --addr ${cfg.address}
          '';

          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RestartSec = 5;
          RestrictRealtime = true;
        };

        startLimitIntervalSec = 10;
        wantedBy = [ "multi-user.target" ];
      };
    }
  );

  meta.maintainers = [ maintainers.mrkkrp ];
}
