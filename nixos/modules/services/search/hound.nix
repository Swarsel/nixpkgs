{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hound;
  settingsFormat = pkgs.formats.json { };
  houndConfigFile = pkgs.writeTextFile {
    checkPhase = ''
      ${cfg.package}/bin/houndd -check-config -conf $out
    '';

    name = "hound-config.json";
    text = builtins.toJSON cfg.settings;
  };
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "hound"
      "extraGroups"
    ] "Use users.users.hound.extraGroups instead")
    (lib.mkChangedOptionModule [ "services" "hound" "config" ] [ "services" "hound" "settings" ] (
      config: builtins.fromJSON config.services.hound.config
    ))
  ];

  options = {
    services.hound = {
      enable = lib.mkEnableOption "hound";
      package = lib.mkPackageOption pkgs "hound" { };

      group = lib.mkOption {
        default = "hound";

        description = ''
          Group the hound daemon should execute under.
        '';

        type = lib.types.str;
      };

      home = lib.mkOption {
        default = "/var/lib/hound";

        description = ''
          The path to use as hound's $HOME.
          If the default user "hound" is configured then this is the home of the "hound" user.
        '';

        type = lib.types.path;
      };

      listen = lib.mkOption {
        default = "0.0.0.0:6080";

        description = ''
          Listen on this [IP]:port
        '';

        example = ":6080";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        description = ''
          The full configuration of the Hound daemon.
          See the upstream documentation <https://github.com/hound-search/hound/blob/main/docs/config-options.md> for details.

          :::{.note}
          The `dbpath` should be an absolute path to a writable directory.
          :::.com/hound-search/hound/blob/main/docs/config-options.md>.
        '';

        example = lib.literalExpression ''
          {
            max-concurrent-indexers = 2;
            repos.nixpkgs.url = "https://www.github.com/NixOS/nixpkgs.git";
          }
        '';

        type = settingsFormat.type;
      };

      user = lib.mkOption {
        default = "hound";

        description = ''
          User the hound daemon should execute under.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."hound/config.json".source = houndConfigFile;

    services.hound.settings = {
      dbpath = "${config.services.hound.home}/data";
    };

    systemd.services.hound = {
      after = [ "network.target" ];
      description = "Hound Code Search";
      restartTriggers = [ houndConfigFile ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/houndd -addr ${cfg.listen} -conf /etc/hound/config.json";
        ExecStartPre = "${pkgs.git}/bin/git config --global --replace-all http.sslCAinfo ${config.security.pki.caBundle}";
        Group = cfg.group;
        User = cfg.user;
        WorkingDirectory = cfg.home;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "hound") {
      hound = { };
    };

    users.users = lib.mkIf (cfg.user == "hound") {
      hound = {
        inherit (cfg) home group;
        createHome = true;
        description = "Hound code search";
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ SuperSandro2000 ];
}
