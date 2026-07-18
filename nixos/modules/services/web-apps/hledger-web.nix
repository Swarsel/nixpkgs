{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.hledger-web;
in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "hledger-web"
      "capabilities"
    ] "This option has been replaced by new option `services.hledger-web.allow`.")
  ];

  options.services.hledger-web = {

    enable = mkEnableOption "hledger-web service";

    allow = mkOption {
      default = "view";

      description = ''
        User's access level for changing data.

        * view: view only permission.
        * add: view and add permissions.
        * edit: view, add, and edit permissions.
        * sandstorm: permissions from the `X-Sandstorm-Permissions` request header.
      '';

      type = types.enum [
        "view"
        "add"
        "edit"
        "sandstorm"
      ];
    };

    baseUrl = mkOption {
      default = null;

      description = ''
        Base URL, when sharing over a network.
      '';

      example = "https://example.org";
      type = with types; nullOr str;
    };

    extraOptions = mkOption {
      default = [ ];

      description = ''
        Extra command line arguments to pass to hledger-web.
      '';

      example = [ "--forecast" ];
      type = types.listOf types.str;
    };

    host = mkOption {
      default = "127.0.0.1";

      description = ''
        Address to listen on.
      '';

      type = types.str;
    };

    journalFiles = mkOption {
      default = [ ".hledger.journal" ];

      description = ''
        Paths to journal files relative to {option}`services.hledger-web.stateDir`.
      '';

      type = types.listOf types.str;
    };

    port = mkOption {
      default = 5000;

      description = ''
        Port to listen on.
      '';

      example = 80;
      type = types.port;
    };

    serveApi = mkEnableOption "serving only the JSON web API, without the web UI";

    stateDir = mkOption {
      default = "/var/lib/hledger-web";

      description = ''
        Path the service has access to. If left as the default value this
        directory will automatically be created before the hledger-web server
        starts, otherwise the sysadmin is responsible for ensuring the
        directory exists with appropriate ownership and permissions.
      '';

      type = types.path;
    };

  };

  config = mkIf cfg.enable {

    systemd.services.hledger-web =
      let
        serverArgs =
          with cfg;
          escapeShellArgs (
            [
              "--serve"
              "--host=${host}"
              "--port=${toString port}"
              "--allow=${allow}"
              (optionalString (cfg.baseUrl != null) "--base-url=${cfg.baseUrl}")
              (optionalString (cfg.serveApi) "--serve-api")
            ]
            ++ (map (f: "--file=${stateDir}/${f}") cfg.journalFiles)
            ++ extraOptions
          );
      in
      {
        after = [ "network.target" ];
        description = "hledger-web - web-app for the hledger accounting tool.";

        documentation = [
          "info:hledger-web"
          "man:hledger-web(1)"
          "https://hledger.org/hledger-web.html"
        ];

        serviceConfig = mkMerge [
          {
            ExecStart = "${pkgs.hledger-web}/bin/hledger-web ${serverArgs}";
            Group = "hledger";
            PrivateTmp = true;
            Restart = "always";
            User = "hledger";
            WorkingDirectory = cfg.stateDir;
          }
          (mkIf (cfg.stateDir == "/var/lib/hledger-web") {
            StateDirectory = "hledger-web";
          })
        ];

        wantedBy = [ "multi-user.target" ];
      };

    users.groups.hledger = { };

    users.users.hledger = {
      group = "hledger";
      home = cfg.stateDir;
      isSystemUser = true;
      name = "hledger";
      useDefaultShell = true;
    };

  };

  meta.maintainers = with lib.maintainers; [
    marijanp
    erictapen
  ];
}
