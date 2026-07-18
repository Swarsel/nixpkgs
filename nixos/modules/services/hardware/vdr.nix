{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.vdr;

  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    optional
    ;
in
{
  options = {

    services.vdr = {
      enable = mkEnableOption "VDR, a video disk recorder";

      package = mkPackageOption pkgs "vdr" {
        example = "wrapVdr.override { plugins = with pkgs.vdrPlugins; [ hello ]; }";
      };

      enableLirc = mkEnableOption "LIRC";

      extraArguments = mkOption {
        default = [ ];
        description = "Additional command line arguments to pass to VDR.";
        type = types.listOf types.str;
      };

      group = mkOption {
        default = "vdr";

        description = ''
          Group under which the VDRvdr service runs.
        '';

        type = types.str;
      };

      user = mkOption {
        default = "vdr";

        description = ''
          User under which the VDR service runs.
        '';

        type = types.str;
      };

      videoDir = mkOption {
        default = "/srv/vdr/video";
        description = "Recording directory";
        type = types.path;
      };
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.vdr = {
      after = [ "network.target" ] ++ optional cfg.enableLirc "lircd.service";
      description = "VDR";

      serviceConfig = {
        CacheDirectory = "vdr";

        ExecStart =
          let
            args = [
              "--video=${cfg.videoDir}"
            ]
            ++ optional cfg.enableLirc "--lirc=${config.passthru.lirc.socket}"
            ++ cfg.extraArguments;
          in
          "${cfg.package}/bin/vdr ${lib.escapeShellArgs args}";

        Group = cfg.group;
        Restart = "on-failure";
        RuntimeDirectory = "vdr";
        StateDirectory = "vdr";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = optional cfg.enableLirc "lircd.service";
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.videoDir} 0755 ${cfg.user} ${cfg.group} -"
      "Z ${cfg.videoDir} - ${cfg.user} ${cfg.group} -"
    ];

    users.groups = mkIf (cfg.group == "vdr") { vdr = { }; };

    users.users = mkIf (cfg.user == "vdr") {
      vdr = {
        inherit (cfg) group;

        extraGroups = [
          "video"
          "audio"
        ]
        ++ optional cfg.enableLirc "lirc";

        home = "/run/vdr";
        isSystemUser = true;
      };
    };

  };
}
