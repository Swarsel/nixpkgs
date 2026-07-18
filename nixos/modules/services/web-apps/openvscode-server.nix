{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.openvscode-server;
  defaultUser = "openvscode-server";
  defaultGroup = defaultUser;
in
{
  options = {
    services.openvscode-server = {
      enable = lib.mkEnableOption "openvscode-server";
      package = lib.mkPackageOption pkgs "openvscode-server" { };

      connectionToken = lib.mkOption {
        default = null;

        description = ''
          A secret that must be included with all requests.
        '';

        example = "secret-token";
        type = lib.types.nullOr lib.types.str;
      };

      connectionTokenFile = lib.mkOption {
        default = null;

        description = ''
          Path to a file that contains the connection token.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      extensionsDir = lib.mkOption {
        default = null;

        description = ''
          Set the root path for extensions.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      extraArguments = lib.mkOption {
        default = [ ];

        description = ''
          Additional arguments to pass to openvscode-server.
        '';

        example = lib.literalExpression ''[ "--log=info" ]'';
        type = lib.types.listOf lib.types.str;
      };

      extraEnvironment = lib.mkOption {
        default = { };

        description = ''
          Additional environment variables to pass to openvscode-server.
        '';

        example = {
          PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
        };

        type = lib.types.attrsOf lib.types.str;
      };

      extraGroups = lib.mkOption {
        default = [ ];

        description = ''
          An array of additional groups for the `${defaultUser}` user.
        '';

        example = [ "docker" ];
        type = lib.types.listOf lib.types.str;
      };

      extraPackages = lib.mkOption {
        default = [ ];

        description = ''
          Additional packages to add to the openvscode-server {env}`PATH`.
        '';

        example = lib.literalExpression "[ pkgs.go ]";
        type = lib.types.listOf lib.types.package;
      };

      group = lib.mkOption {
        default = defaultGroup;

        description = ''
          The group to run openvscode-server under.
          By default, a group named `${defaultGroup}` will be created.
        '';

        example = "yourGroup";
        type = lib.types.str;
      };

      host = lib.mkOption {
        default = "localhost";

        description = ''
          The host name or IP address the server should listen to.
        '';

        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 3000;

        description = ''
          The port the server should listen to. If 0 is passed a random free port is picked. If a range in the format num-num is passed, a free port from the range (end inclusive) is selected.
        '';

        type = lib.types.port;
      };

      serverDataDir = lib.mkOption {
        default = null;

        description = ''
          Specifies the directory that server data is kept in.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      socketPath = lib.mkOption {
        default = null;

        description = ''
          The path to a socket file for the server to listen to.
        '';

        example = "/run/openvscode/socket";
        type = lib.types.nullOr lib.types.str;
      };

      telemetryLevel = lib.mkOption {
        default = null;

        description = ''
          Sets the initial telemetry level. Valid levels are: 'off', 'crash', 'error' and 'all'.
        '';

        example = "crash";

        type = lib.types.nullOr (
          lib.types.enum [
            "off"
            "crash"
            "error"
            "all"
          ]
        );
      };

      user = lib.mkOption {
        default = defaultUser;

        description = ''
          The user to run openvscode-server as.
          By default, a user named `${defaultUser}` will be created.
        '';

        example = "yourUser";
        type = lib.types.str;
      };

      userDataDir = lib.mkOption {
        default = null;

        description = ''
          Specifies the directory that user data is kept in. Can be used to open multiple distinct instances of Code.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      withoutConnectionToken = lib.mkOption {
        default = false;

        description = ''
          Run without a connection token. Only use this if the connection is secured by other means.
        '';

        example = true;
        type = lib.types.bool;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.openvscode-server = {
      after = [ "network-online.target" ];
      description = "OpenVSCode server";
      environment = cfg.extraEnvironment;
      path = cfg.extraPackages;

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        ExecStart = ''
          ${lib.getExe cfg.package} \
            --accept-server-license-terms \
            --host=${cfg.host} \
            --port=${toString cfg.port} \
        ''
        + lib.optionalString (cfg.telemetryLevel != null) ''
          --telemetry-level=${cfg.telemetryLevel} \
        ''
        + lib.optionalString (cfg.withoutConnectionToken) ''
          --without-connection-token \
        ''
        + lib.optionalString (cfg.socketPath != null) ''
          --socket-path=${cfg.socketPath} \
        ''
        + lib.optionalString (cfg.userDataDir != null) ''
          --user-data-dir=${cfg.userDataDir} \
        ''
        + lib.optionalString (cfg.serverDataDir != null) ''
          --server-data-dir=${cfg.serverDataDir} \
        ''
        + lib.optionalString (cfg.extensionsDir != null) ''
          --extensions-dir=${cfg.extensionsDir} \
        ''
        + lib.optionalString (cfg.connectionToken != null) ''
          --connection-token=${cfg.connectionToken} \
        ''
        + lib.optionalString (cfg.connectionTokenFile != null) ''
          --connection-token-file=${cfg.connectionTokenFile} \
        ''
        + lib.escapeShellArgs cfg.extraArguments;

        Group = cfg.group;
        Restart = "on-failure";
        RuntimeDirectory = cfg.user;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups."${defaultGroup}" = lib.mkIf (cfg.group == defaultGroup) { };

    users.users."${cfg.user}" = lib.mkMerge [
      (lib.mkIf (cfg.user == defaultUser) {
        inherit (cfg) group;
        description = "openvscode-server user";
        isNormalUser = true;
      })
      {
        inherit (cfg) extraGroups;
        packages = cfg.extraPackages;
      }
    ];
  };

  meta.maintainers = [ ];
}
