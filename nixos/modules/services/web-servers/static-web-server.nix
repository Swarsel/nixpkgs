{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.static-web-server;
  toml = pkgs.formats.toml { };
  configFilePath = toml.generate "config.toml" cfg.configuration;
in
{
  options = {
    services.static-web-server = {
      enable = lib.mkEnableOption "Static Web Server";

      configuration = lib.mkOption {
        default = { };

        description = ''
          Configuration for Static Web Server. See
          <https://static-web-server.net/configuration/config-file/>.
          NOTE: Don't set "host", "port", or "root" here. They will be ignored.
          Use the top-level "listen" and "root" options instead.
        '';

        example = {
          general = {
            directory-listing = true;
            log-level = "error";
          };
        };

        type = toml.type;
      };

      listen = lib.mkOption {
        default = "[::]:8787";

        description = ''
          The {manpage}`systemd.socket(5)` "ListenStream" used in static-web-server.socket.
          This is equivalent to SWS's "host" and "port" options.
          See here for specific syntax: <https://www.freedesktop.org/software/systemd/man/systemd.socket.html#ListenStream=>
        '';

        type = lib.types.str;
      };

      root = lib.mkOption {
        description = ''
          The location of files for SWS to serve. Equivalent to SWS's "root" config value.
          NOTE: This folder must exist before starting SWS.
        '';

        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.static-web-server ];
    systemd.packages = [ pkgs.static-web-server ];

    systemd.services.static-web-server = {
      serviceConfig = {
        BindReadOnlyPaths = cfg.root;
        # Remove upstream sample environment file; use config.toml exclusively
        EnvironmentFile = [ "" ];

        ExecStart = [
          ""
          "${pkgs.static-web-server}/bin/static-web-server --fd 0 --config-file ${configFilePath} --root ${cfg.root}"
        ];

        # If the user is serving files from their home dir, override ProtectHome to allow that
        ProtectHome = if lib.hasPrefix "/home" cfg.root then "tmpfs" else "true";
        # Supplementary groups doesn't work unless we create the group ourselves
        SupplementaryGroups = [ "" ];
      };

      wantedBy = [ "multi-user.target" ];
    };

    # Have to set wantedBy since systemd.packages ignores the "Install" section
    systemd.sockets.static-web-server = {
      # Start with empty string to reset upstream option
      listenStreams = [
        ""
        cfg.listen
      ];

      wantedBy = [ "sockets.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ mac-chaffee ];
}
