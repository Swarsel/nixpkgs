{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tdarr;
in
{
  imports = [
    ./server.nix
    ./node.nix
  ];

  options.services.tdarr = {
    enable = lib.mkEnableOption "Tdarr distributed transcoding system" // {
      description = ''
        Whether to enable Tdarr. This is a convenience option that enables both
        the server and all configured nodes. For more granular control, use
        {option}`services.tdarr.server.enable` and configure nodes individually.
      '';
    };

    package = lib.mkPackageOption pkgs "tdarr" { };

    dataDir = lib.mkOption {
      default = "/var/lib/tdarr";
      description = "Base directory for Tdarr data.";
      type = lib.types.path;
    };

    group = lib.mkOption {
      default = "tdarr";
      description = "Group under which Tdarr runs.";
      type = lib.types.str;
    };

    user = lib.mkOption {
      default = "tdarr";
      description = "User account under which Tdarr runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf (cfg.enable || cfg.server.enable || cfg.nodes != { }) {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
    ];

    users.groups.tdarr = lib.mkIf (cfg.group == "tdarr") { };

    users.users.tdarr = lib.mkIf (cfg.user == "tdarr") {
      createHome = true;
      group = cfg.group;
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };

  meta = {
    doc = ./tdarr.md;
    maintainers = with lib.maintainers; [ mistyttm ];
  };
}
