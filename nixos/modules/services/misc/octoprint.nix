{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.octoprint;

  baseConfig = lib.recursiveUpdate {
    plugins.curalegacy.cura_engine = "${pkgs.curaengine_stable}/bin/CuraEngine";
    server.port = cfg.port;
    webcam.ffmpeg = "${pkgs.ffmpeg-headless.bin}/bin/ffmpeg";
  } (lib.optionalAttrs (cfg.host != null) { server.host = cfg.host; });

  fullConfig = lib.recursiveUpdate cfg.extraConfig baseConfig;

  cfgUpdate = pkgs.writeText "octoprint-config.yaml" (builtins.toJSON fullConfig);

  pluginsEnv = cfg.package.python.withPackages (ps: [ ps.octoprint ] ++ (cfg.plugins ps));

in
{
  ##### interface

  options = {

    services.octoprint = {

      enable = lib.mkEnableOption "OctoPrint, web interface for 3D printers";
      package = lib.mkPackageOption pkgs "octoprint" { };

      extraConfig = lib.mkOption {
        default = { };
        description = "Extra options which are added to OctoPrint's YAML configuration file.";
        type = lib.types.attrs;
      };

      group = lib.mkOption {
        default = "octoprint";
        description = "Group for the daemon.";
        type = lib.types.str;
      };

      host = lib.mkOption {
        default = null;

        description = ''
          Host to bind OctoPrint to.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for OctoPrint.";
        type = lib.types.bool;
      };

      plugins = lib.mkOption {
        default = plugins: [ ];
        defaultText = lib.literalExpression "plugins: []";
        description = "Additional plugins to be used. Available plugins are passed through the plugins input.";
        example = lib.literalExpression "plugins: with plugins; [ themeify stlviewer ]";
        type = lib.types.functionTo (lib.types.listOf lib.types.package);
      };

      port = lib.mkOption {
        default = 5000;

        description = ''
          Port to bind OctoPrint to.
        '';

        type = lib.types.port;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/octoprint";
        description = "State directory of the daemon.";
        type = lib.types.path;
      };

      user = lib.mkOption {
        default = "octoprint";
        description = "User for the daemon.";
        type = lib.types.str;
      };

    };

  };

  ##### implementation

  config = lib.mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.octoprint = {
      after = [ "network.target" ];
      description = "OctoPrint, web interface for 3D printers";
      path = [ pluginsEnv ];

      preStart = ''
        if [ -e "${cfg.stateDir}/config.yaml" ]; then
          ${pkgs.yaml-merge}/bin/yaml-merge "${cfg.stateDir}/config.yaml" "${cfgUpdate}" > "${cfg.stateDir}/config.yaml.tmp"
          mv "${cfg.stateDir}/config.yaml.tmp" "${cfg.stateDir}/config.yaml"
        else
          cp "${cfgUpdate}" "${cfg.stateDir}/config.yaml"
          chmod 600 "${cfg.stateDir}/config.yaml"
        fi
      '';

      serviceConfig = {
        ExecStart = "${pluginsEnv}/bin/octoprint serve -b ${cfg.stateDir}";
        Group = cfg.group;

        SupplementaryGroups = [
          "dialout"
        ];

        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' - ${cfg.user} ${cfg.group} - -"
      # this will allow octoprint access to raspberry specific hardware to check for throttling
      # read-only will not work: "VCHI initialization failed" error
      "a /dev/vchiq - - - - u:octoprint:rw"
    ];

    users.groups = lib.optionalAttrs (cfg.group == "octoprint") {
      octoprint.gid = config.ids.gids.octoprint;
    };

    users.users = lib.optionalAttrs (cfg.user == "octoprint") {
      octoprint = {
        group = cfg.group;
        uid = config.ids.uids.octoprint;
      };
    };
  };
}
