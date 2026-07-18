{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.zerobin;

  zerobin_config = pkgs.writeText "zerobin-config.py" ''
    PASTE_FILES_ROOT = "${cfg.dataDir}"
    ${cfg.extraConfig}
  '';

in
{
  options = {
    services.zerobin = {
      enable = mkEnableOption "0bin";

      dataDir = mkOption {
        default = "/var/lib/zerobin";

        description = ''
          Path to the 0bin data directory
        '';

        type = types.str;
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Extra configuration to be appended to the 0bin config file
          (see <https://0bin.readthedocs.org/en/latest/en/options.html>)
        '';

        example = ''
          MENU = (
          ('Home', '/'),
          )
          COMPRESSED_STATIC_FILE = True
        '';

        type = types.lines;
      };

      group = mkOption {
        default = "zerobin";

        description = ''
          The group 0bin should run as
        '';

        type = types.str;
      };

      listenAddress = mkOption {
        default = "localhost";

        description = ''
          The address zerobin should listen to
        '';

        example = "127.0.0.1";
        type = types.str;
      };

      listenPort = mkOption {
        default = 8000;

        description = ''
          The port zerobin should listen on
        '';

        example = 1357;
        type = types.port;
      };

      user = mkOption {
        default = "zerobin";

        description = ''
          The user 0bin should run as
        '';

        type = types.str;
      };
    };
  };

  config = mkIf (cfg.enable) {
    systemd.services.zerobin = {
      enable = true;
      after = [ "network.target" ];

      preStart = ''
        mkdir -p ${cfg.dataDir}
        chown ${cfg.user} ${cfg.dataDir}
      '';

      serviceConfig.ExecStart = "${pkgs.zerobin}/bin/zerobin ${cfg.listenAddress} ${toString cfg.listenPort} false ${cfg.user} ${cfg.group} ${zerobin_config}";
      serviceConfig.Group = cfg.group;
      serviceConfig.PrivateTmp = "yes";
      serviceConfig.User = cfg.user;
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = optionalAttrs (cfg.user == "zerobin") {
      createHome = true;
      group = cfg.group;
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };
}
