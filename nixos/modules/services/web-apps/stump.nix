{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.stump;

  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;

  secret = types.nullOr (
    types.str
    // {
      # We don't want users to be able to pass a path literal here but
      # it should look like a path.
      check = it: lib.isString it && lib.types.path.check it;
    }
  );
in
{
  options.services.stump = {
    enable = mkEnableOption "Stump";
    package = lib.mkPackageOption pkgs "stump" { };

    configLocation = mkOption {
      default = "/var/lib/stump";
      description = "Directory used to store the database and configuration files. If it is not the default, the directory has to be created manually such that the stump user is able to read and write to it.";
      type = types.path;
    };

    environment = mkOption {
      default = { };

      description = ''
        Extra configuration environment variables. Refer to the [documentation](https://www.stumpapp.dev/docs/guides/configuration/server-config) for options.
      '';

      example = {
        STUMP_VERBOSITY = "2";
      };

      type = types.attrsOf types.str;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path of a file with extra environment variables to be loaded from disk.
        This file is not added to the nix store, so it can be used to pass secrets to stump.
        Refer to the [documentation](https://www.stumpapp.dev/docs/guides/configuration/server-config) for options.
      '';

      example = "/run/secrets/stump";
      type = secret;
    };

    group = mkOption {
      default = "stump";
      description = "The group stump should run as.";
      type = types.str;
    };

    ip = mkOption {
      default = "127.0.0.1";
      description = "The IP address that Stump will listen on.";
      type = types.str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Whether to open the Stump port in the firewall";
      type = types.bool;
    };

    port = mkOption {
      default = 10001;
      description = "The port that Stump will listen on.";
      type = types.port;
    };

    secretFiles = mkOption {
      default = { };

      description = ''
        Attribute set containing paths to files to add to the environment of stump.
        The files are not added to the nix store, so they can be used to pass secrets to stump.
        Refer to the [documentation](https://www.stumpapp.dev/docs/guides/configuration/server-config) for options.
      '';

      example = {
        STUMP_OIDC_CLIENT_SECRET = "/run/secrets/stump_client_secret";
      };

      type = types.attrsOf secret;
    };

    user = mkOption {
      default = "stump";
      description = "The user Stump should run as.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    services.stump.environment = {
      STUMP_CONFIG_DIR = cfg.configLocation;
      STUMP_IP = cfg.ip;
      STUMP_PORT = toString cfg.port;
    };

    systemd.services.stump = {
      after = [ "network-online.target" ];
      description = "Stump (A free and open source comics, manga and digital book server with OPDS support)";
      environment = cfg.environment;
      requires = [ "network-online.target" ];

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        EnvironmentFile = cfg.environmentFile;

        ExecStart =
          if cfg.secretFiles == { } then
            "${lib.getExe cfg.package}"
          else
            pkgs.writeShellScript "stump-env" ''
              ${lib.strings.concatStringsSep "\n" (
                lib.attrsets.mapAttrsToList (key: path: "export ${key}=$(< \"${path}\")") cfg.secretFiles
              )}
              ${lib.getExe cfg.package}
            '';

        Group = cfg.group;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";
        RestartSec = 3;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK" # is used to determine local ip
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "stump";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = mkIf (cfg.group == "stump") { stump = { }; };

    users.users = mkIf (cfg.user == "stump") {
      stump = {
        group = cfg.group;
        isSystemUser = true;
        name = "stump";
      };
    };

    meta.maintainers = with lib.maintainers; [ jvanbruegge ];
  };
}
