{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gonic;
  settingsFormat = pkgs.formats.keyValue {
    listsAsDuplicateKeys = true;
    mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
  };
  assertKey = key: {
    assertion = cfg.settings ? ${key};
    message = "Please set services.gonic.settings.${key}. See https://github.com/sentriz/gonic#configuration-options for supported values.";
  };
in
{
  options = {
    services.gonic = {

      enable = lib.mkEnableOption "Gonic music server";
      package = lib.mkPackageOption pkgs "gonic" { };

      settings = lib.mkOption rec {
        apply = lib.recursiveUpdate default;

        default = {
          cache-path = "/var/cache/gonic";
          listen-addr = "127.0.0.1:4747";
          tls-cert = null;
          tls-key = null;
        };

        description = ''
          Configuration for Gonic, see <https://github.com/sentriz/gonic#configuration-options> for supported values.
        '';

        example = {
          music-path = [ "/mnt/music" ];
          playlists-path = "/mnt/playlists";
          podcast-path = "/mnt/podcasts";
        };

        type = settingsFormat.type;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (assertKey "music-path")
      (assertKey "podcast-path")
      (assertKey "playlists-path")
    ];

    systemd.services.gonic = {
      after = [ "network.target" ];
      description = "Gonic Media Server";

      serviceConfig = {
        BindPaths = [
          cfg.settings.playlists-path
          cfg.settings.podcast-path
          cfg.settings.cache-path
        ];

        BindReadOnlyPaths = [
          # gonic can access scrobbling services
          "-/etc/resolv.conf"
          "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
          builtins.storeDir
        ]
        ++ cfg.settings.music-path
        ++ lib.optional (cfg.settings.tls-cert != null) cfg.settings.tls-cert
        ++ lib.optional (cfg.settings.tls-key != null) cfg.settings.tls-key;

        CacheDirectory = "gonic";
        CapabilityBoundingSet = "";

        ExecStart =
          let
            # these values are null by default but should not appear in the final config
            filteredSettings = lib.filterAttrs (
              n: v: !((n == "tls-cert" || n == "tls-key") && v == null)
            ) cfg.settings;
          in
          "${lib.getExe cfg.package} -config-path ${settingsFormat.generate "gonic" filteredSettings}";

        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
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
        RootDirectory = "/run/gonic";
        RuntimeDirectory = "gonic";
        StateDirectory = "gonic";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0066";
        WorkingDirectory = "/var/lib/gonic";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.autrimpo ];
}
