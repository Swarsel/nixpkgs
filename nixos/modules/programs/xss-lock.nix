{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.xss-lock;
in
{
  options.programs.xss-lock = {
    enable = lib.mkEnableOption "xss-lock";

    extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Additional command-line arguments to pass to
        {command}`xss-lock`.
      '';

      example = [ "--ignore-sleep" ];
      type = lib.types.listOf lib.types.str;
    };

    lockerCommand = lib.mkOption {
      default = "${pkgs.i3lock}/bin/i3lock";
      defaultText = lib.literalExpression ''"''${pkgs.i3lock}/bin/i3lock"'';
      description = "Locker to be used with xsslock";
      example = lib.literalExpression ''"''${pkgs.i3lock-fancy}/bin/i3lock-fancy"'';
      type = lib.types.separatedString " ";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.xss-lock = {
      description = "XSS Lock Daemon";
      partOf = [ "graphical-session.target" ];

      serviceConfig.ExecStart = builtins.concatStringsSep " " (
        [
          "${pkgs.xss-lock}/bin/xss-lock"
          "--session \${XDG_SESSION_ID}"
        ]
        ++ (map lib.escapeShellArg cfg.extraOptions)
        ++ [
          "--"
          cfg.lockerCommand
        ]
      );

      serviceConfig.Restart = "always";
      wantedBy = [ "graphical-session.target" ];
    };
  };
}
