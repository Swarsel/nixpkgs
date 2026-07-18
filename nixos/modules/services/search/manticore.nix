{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.manticore;
  format = pkgs.formats.json { };

  toSphinx =
    {
      listsAsDuplicateKeys ? true,
      mkKeyValue ? lib.generators.mkKeyValueDefault { } "=",
    }:
    attrsOfAttrs:
    let
      # map function to string for each key val
      mapAttrsToStringsSep =
        sep: mapFn: attrs:
        lib.concatStringsSep sep (lib.mapAttrsToList mapFn attrs);
      mkSection =
        sectName: sectValues:
        ''
          ${sectName} {
        ''
        + lib.generators.toKeyValue { inherit mkKeyValue listsAsDuplicateKeys; } sectValues
        + "}";
    in
    # map input to ini sections
    mapAttrsToStringsSep "\n" mkSection attrsOfAttrs;

  configFile = pkgs.writeText "manticore.conf" (
    toSphinx {
      mkKeyValue = k: v: "  ${k} = ${v}";
    } cfg.settings
  );

in
{

  options = {
    services.manticore = {

      enable = lib.mkEnableOption "Manticoresearch";

      settings = lib.mkOption {
        default = {
          searchd = {
            data_dir = "/var/lib/manticore";

            listen = [
              "127.0.0.1:9312"
              "127.0.0.1:9306:mysql"
              "127.0.0.1:9308:http"
            ];

            log = "/var/log/manticore/searchd.log";
            pid_file = "/run/manticore/searchd.pid";
            query_log = "/var/log/manticore/query.log";
          };
        };

        description = ''
          Configuration for Manticoresearch. See
          <https://manual.manticoresearch.com/Server%20settings>
          for more information.
        '';

        example = lib.literalExpression ''
          {
            searchd = {
                listen = [
                  "127.0.0.1:9312"
                  "127.0.0.1:9306:mysql"
                  "127.0.0.1:9308:http"
                ];
                log = "/var/log/manticore/searchd.log";
                query_log = "/var/log/manticore/query.log";
                pid_file = "/run/manticore/searchd.pid";
                data_dir = "/var/lib/manticore";
            };
          }
        '';

        type = lib.types.submodule {
          freeformType = format.type;
        };
      };

    };
  };

  config = lib.mkIf cfg.enable {

    systemd = {
      packages = [ pkgs.manticoresearch ];

      services.manticore = {
        after = [ "network.target" ];

        serviceConfig = {
          CapabilityBoundingSet = "";
          DynamicUser = true;

          ExecStart = [
            ""
            "${pkgs.manticoresearch}/bin/searchd --config ${configFile}"
          ];

          ExecStartPre = [ "" ];

          ExecStop = [
            ""
            "${pkgs.manticoresearch}/bin/searchd --config ${configFile} --stopwait"
          ];

          LockPersonality = true;
          LogsDirectory = "manticore";
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ReadWritePaths = "";

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RuntimeDirectory = "manticore";
          StateDirectory = "manticore";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          UMask = "0066";
        }
        // lib.optionalAttrs (cfg.settings.searchd.pid_file != null) {
          PIDFile = cfg.settings.searchd.pid_file;
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

  };

  meta.maintainers = with lib.maintainers; [ onny ];

}
