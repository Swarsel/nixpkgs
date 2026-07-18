{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.weechat;
in
{
  options.services.weechat = {
    enable = lib.mkEnableOption "weechat";
    package = lib.mkPackageOption pkgs "weechat" { };

    binary = lib.mkOption {
      default =
        if (!cfg.headless) then "${cfg.package}/bin/weechat" else "${cfg.package}/bin/weechat-headless";

      defaultText = lib.literalExpression ''"''${cfg.package}/bin/weechat"'';
      description = "Binary to execute.";
      example = lib.literalExpression ''"''${cfg.package}/bin/weechat-headless"'';
      type = lib.types.path;
    };

    headless = lib.mkOption {
      default = false;

      description = ''
        Allows specifying if weechat should run in TUI or headless mode.
      '';

      type = lib.types.bool;
    };

    root = lib.mkOption {
      default = "/var/lib/weechat";
      description = "Weechat state directory.";
      type = lib.types.path;
    };

    sessionName = lib.mkOption {
      default = "weechat-screen";
      description = "Name of the `screen` session for weechat.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    security.wrappers.screen = lib.mkIf (!cfg.headless) {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${pkgs.screen}/bin/screen";
    };

    systemd.services.weechat = {
      script =
        lib.mkIf (!cfg.headless)
          "exec ${config.security.wrapperDir}/screen -Dm -S ${cfg.sessionName} ${cfg.binary} --dir ${cfg.root}";

      serviceConfig = {
        ExecStart = lib.mkIf (cfg.headless) "${cfg.binary} --dir ${cfg.root} --stdout";
        Group = "weechat";
        RemainAfterExit = "yes";
        StateDirectory = lib.mkIf (cfg.root == "/var/lib/weechat") "weechat";
        StateDirectoryMode = 750;
        Type = "simple";
        User = "weechat";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };

    systemd.tmpfiles.settings."weechat" = {
      "${cfg.root}" = lib.mkIf (cfg.root != "/var/lib/weechat") {
        d = {
          group = "weechat";
          mode = "750";
          user = "weechat";
        };
      };
    };

    users = {
      groups.weechat = { };

      users.weechat = {
        createHome = true;
        group = "weechat";
        home = cfg.root;
        isSystemUser = true;
      };
    };
  };

  meta.doc = ./weechat.md;
}
