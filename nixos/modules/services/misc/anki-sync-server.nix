{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.anki-sync-server;
  name = "anki-sync-server";
  specEscape = replaceStrings [ "%" ] [ "%%" ];
  usersWithIndexes = lists.imap1 (i: user: {
    i = i;
    user = user;
  }) cfg.users;
  usersWithIndexesFile = filter (x: x.user.passwordFile != null) usersWithIndexes;
  usersWithIndexesNoFile = filter (
    x: x.user.passwordFile == null && x.user.password != null
  ) usersWithIndexes;
  anki-sync-server-run = pkgs.writeShellScript "anki-sync-server-run" ''
    # When services.anki-sync-server.users.passwordFile is set,
    # each password file is passed as a systemd credential, which is mounted in
    # a file system exposed to the service. Here we read the passwords from
    # the credential files to pass them as environment variables to the Anki
    # sync server.
    ${concatMapStringsSep "\n" (x: ''
      read -r pass < "''${CREDENTIALS_DIRECTORY}/"${escapeShellArg x.user.username}
      export SYNC_USER${toString x.i}=${escapeShellArg x.user.username}:"$pass"
    '') usersWithIndexesFile}
    # For users where services.anki-sync-server.users.password isn't set,
    # export passwords in environment variables in plaintext.
    ${concatMapStringsSep "\n" (
      x:
      "export SYNC_USER${toString x.i}=${escapeShellArg x.user.username}:${escapeShellArg x.user.password}"
    ) usersWithIndexesNoFile}
    exec ${lib.getExe cfg.package}
  '';
in
{
  options.services.anki-sync-server = {
    enable = mkEnableOption "anki-sync-server";
    package = mkPackageOption pkgs "anki-sync-server" { };

    address = mkOption {
      default = "::1";

      description = ''
        IP address anki-sync-server listens to.
        Note host names are not resolved.
      '';

      type = types.str;
    };

    baseDirectory = mkOption {
      default = "%S/%N";
      description = "Base directory where user(s) synchronized data will be stored.";
      type = types.str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Whether to open the firewall for the specified port.";
      type = types.bool;
    };

    port = mkOption {
      default = 27701;
      description = "Port number anki-sync-server listens to.";
      type = types.port;
    };

    users = mkOption {
      description = "List of user-password pairs to provide to the sync server.";

      type =
        with types;
        listOf (submodule {
          options = {
            password = mkOption {
              default = null;

              description = ''
                Password accepted by anki-sync-server for the associated username.
                **WARNING**: This option is **not secure**. This password will
                be stored in *plaintext* and will be visible to *all users*.
                See {option}`services.anki-sync-server.users.passwordFile` for
                a more secure option.
              '';

              type = nullOr str;
            };

            passwordFile = mkOption {
              default = null;

              description = ''
                File containing the password accepted by anki-sync-server for
                the associated username.  Make sure to make readable only by
                root.
              '';

              type = nullOr path;
            };

            username = mkOption {
              description = "User name accepted by anki-sync-server.";
              type = str;
            };
          };
        });
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (builtins.length usersWithIndexesFile) + (builtins.length usersWithIndexesNoFile) > 0;
        message = "At least one username-password pair must be set.";
      }
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.anki-sync-server = {
      after = [ "network.target" ];
      description = "anki-sync-server: Anki sync server built into Anki";

      environment = {
        SYNC_BASE = cfg.baseDirectory;
        SYNC_HOST = specEscape cfg.address;
        SYNC_PORT = toString cfg.port;
      };

      path = [ cfg.package ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = anki-sync-server-run;

        LoadCredential = map (
          x: "${specEscape x.user.username}:${specEscape (toString x.user.passwordFile)}"
        ) usersWithIndexesFile;

        Restart = "always";
        StateDirectory = name;
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    doc = ./anki-sync-server.md;
    maintainers = with maintainers; [ telotortium ];
  };
}
