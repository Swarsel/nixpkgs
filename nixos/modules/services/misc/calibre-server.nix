{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let

  cfg = config.services.calibre-server;

  documentationLink = "https://manual.calibre-ebook.com";
  generatedDocumentationLink = documentationLink + "/generated/en/calibre-server.html";

  execFlags =
    lib.mapAttrsToList (k: v: "--${k}=${toString v}") (
      lib.filterAttrs (name: value: value != null) {
        auth-mode = cfg.auth.mode;
        listen-on = cfg.host;
        port = cfg.port;
        userdb = cfg.auth.userDb;
      }
    )
    ++ lib.optional cfg.auth.enable "--enable-auth"
    ++ cfg.extraFlags;
in

{
  imports = [
    (lib.mkChangedOptionModule
      [ "services" "calibre-server" "libraryDir" ]
      [ "services" "calibre-server" "libraries" ]
      (
        config:
        let
          libraryDir = lib.getAttrFromPath [ "services" "calibre-server" "libraryDir" ] config;
        in
        [ libraryDir ]
      )
    )
  ];

  options = {
    services.calibre-server = {

      enable = lib.mkEnableOption "calibre-server (e-book software)";
      package = lib.mkPackageOption pkgs "calibre" { };

      auth = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Password based authentication to access the server.
            See the [calibre-server documentation](${generatedDocumentationLink}#cmdoption-calibre-server-enable-auth) for details.
          '';

          type = lib.types.bool;
        };

        mode = lib.mkOption {
          default = "auto";

          description = ''
            Choose the type of authentication used.
            Set the HTTP authentication mode used by the server.
            See the [calibre-server documentation](${generatedDocumentationLink}#cmdoption-calibre-server-auth-mode) for details.
          '';

          type = lib.types.enum [
            "auto"
            "basic"
            "digest"
          ];
        };

        userDb = lib.mkOption {
          default = null;

          description = ''
            Choose users database file to use for authentication.
            Make sure users database file is initialized before service startup.
            See the [calibre-server documentation](${documentationLink}/server.html#managing-user-accounts-from-the-command-line-only) for details.
          '';

          type = lib.types.nullOr lib.types.path;
        };
      };

      extraFlags = lib.mkOption {
        default = [ ];

        description = ''
          Extra flags to pass to the calibre-server command.
          See the [calibre-server documentation](${generatedDocumentationLink}) for details.
        '';

        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = "calibre-server";
        description = "The group under which calibre-server runs.";
        type = lib.types.str;
      };

      host = lib.mkOption {
        default = "0.0.0.0";

        description = ''
          The interface on which to listen for connections.
          See the [calibre-server documentation](${generatedDocumentationLink}#cmdoption-calibre-server-listen-on) for details.
        '';

        example = "::1";
        type = lib.types.str;
      };

      libraries = lib.mkOption {
        default = [ "/var/lib/calibre-server" ];

        description = ''
          Make sure each library path is initialized before service startup.
          The directories of the libraries to serve. They must be readable for the user under which the server runs.
          See the [calibredb documentation](${documentationLink}/generated/en/calibredb.html#add) for details.
        '';

        type = lib.types.listOf lib.types.path;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the Calibre Server web interface.";
        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 8080;

        description = ''
          The port on which to listen for connections.
          See the [calibre-server documentation](${generatedDocumentationLink}#cmdoption-calibre-server-port) for details.
        '';

        type = lib.types.port;
      };

      user = lib.mkOption {
        default = "calibre-server";
        description = "The user under which calibre-server runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.calibre-server = {
      after = [ "network.target" ];
      description = "Calibre Server";

      serviceConfig = {
        ExecStart = utils.escapeSystemdExecArgs (
          [ "${cfg.package}/bin/calibre-server" ] ++ execFlags ++ [ "--" ] ++ cfg.libraries
        );

        Restart = "always";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];

    };

    users.groups = lib.optionalAttrs (cfg.group == "calibre-server") {
      calibre-server = {
        gid = config.ids.gids.calibre-server;
      };
    };

    users.users = lib.optionalAttrs (cfg.user == "calibre-server") {
      calibre-server = {
        createHome = true;
        group = cfg.group;
        home = "/var/lib/calibre-server";
        uid = config.ids.uids.calibre-server;
      };
    };

  };

  meta.maintainers = [ ];
}
