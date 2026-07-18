{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.kavita;
  settingsFormat = pkgs.formats.json { };
  appsettings = settingsFormat.generate "appsettings.json" (
    { TokenKey = "@TOKEN@"; } // cfg.settings
  );
in
{
  imports = [
    (lib.mkChangedOptionModule
      [ "services" "kavita" "ipAdresses" ]
      [ "services" "kavita" "settings" "IpAddresses" ]
      (
        config:
        let
          value = lib.getAttrFromPath [ "services" "kavita" "ipAdresses" ] config;
        in
        lib.concatStringsSep "," value
      )
    )
    (lib.mkRenamedOptionModule [ "services" "kavita" "port" ] [ "services" "kavita" "settings" "Port" ])
  ];

  options.services.kavita = {
    enable = lib.mkEnableOption "Kavita reading server";
    package = lib.mkPackageOption pkgs "kavita" { };

    dataDir = lib.mkOption {
      default = "/var/lib/kavita";
      description = "The directory where Kavita stores its state.";
      type = lib.types.str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Kavita configuration options, as configured in {file}`appsettings.json`.
      '';

      type = lib.types.submodule {
        options = {
          IpAddresses = lib.mkOption {
            default = "0.0.0.0,::";

            description = ''
              IP Addresses to bind to. The default is to bind to all IPv4 and IPv6 addresses.
            '';

            type = lib.types.commas;
          };

          Port = lib.mkOption {
            default = 5000;
            description = "Port to bind to.";
            type = lib.types.port;
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    tokenKeyFile = lib.mkOption {
      description = ''
        A file containing the TokenKey, a secret with at 512+ bits.
        It can be generated with `head -c 64 /dev/urandom | base64 --wrap=0`.
      '';

      type = lib.types.path;
    };

    user = lib.mkOption {
      default = "kavita";
      description = "User account under which Kavita runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.kavita = {
      after = [ "network.target" ];
      description = "Kavita";

      preStart = ''
        install -m600 ${appsettings} ${lib.escapeShellArg cfg.dataDir}/config/appsettings.json
        ${pkgs.replace-secret}/bin/replace-secret '@TOKEN@' \
          ''${CREDENTIALS_DIRECTORY}/token \
          '${cfg.dataDir}/config/appsettings.json'
      '';

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        LoadCredential = [ "token:${cfg.tokenKeyFile}" ];
        Restart = "always";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}'        0750 ${cfg.user} ${cfg.user} - -"
      "d '${cfg.dataDir}/config' 0750 ${cfg.user} ${cfg.user} - -"
    ];

    users = {
      groups.${cfg.user} = { };

      users.${cfg.user} = {
        description = "kavita service user";
        group = cfg.user;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ misterio77 ];
}
