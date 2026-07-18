{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.emacs;

  editorScript = pkgs.writeShellScriptBin "emacseditor" ''
    if [ -z "$1" ]; then
      exec ${cfg.package}/bin/emacsclient --create-frame --alternate-editor ${cfg.package}/bin/emacs
    else
      exec ${cfg.package}/bin/emacsclient --alternate-editor ${cfg.package}/bin/emacs "$@"
    fi
  '';

in
{

  options.services.emacs = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable a user service for the Emacs daemon. Use `emacsclient` to connect to the
        daemon. If `true`, {var}`services.emacs.install` is
        considered `true`.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "emacs" { };

    defaultEditor = lib.mkOption {
      default = false;

      description = ''
        When enabled, configures emacsclient to be the default editor
        using the EDITOR environment variable.
      '';

      type = lib.types.bool;
    };

    install = lib.mkOption {
      default = false;

      description = ''
        Whether to install a user service for the Emacs daemon. Once
        the service is started, use emacsclient to connect to the
        daemon.

        The service must be manually started for each user with
        "systemctl --user start emacs" or globally through
        {var}`services.emacs.enable`.
      '';

      type = lib.types.bool;
    };

    startWithGraphical = lib.mkOption {
      default = config.services.xserver.enable;
      defaultText = lib.literalExpression "config.services.xserver.enable";

      description = ''
        Start emacs with the graphical session instead of any session. Without this, emacs clients will not be able to create frames in the graphical session.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
    environment.sessionVariables.EDITOR = lib.mkIf cfg.defaultEditor (lib.mkOverride 900 "emacseditor");

    environment.systemPackages = [
      cfg.package
      editorScript
    ];

    systemd.user.services.emacs = {
      description = "Emacs: the extensible, self-documenting text editor";
      # Long-lived session that ought to only be restarted manually
      restartIfChanged = false;

      serviceConfig = {
        ExecStart = "${pkgs.runtimeShell} -c 'source ${config.system.build.setEnvironment}; exec ${cfg.package}/bin/emacs --fg-daemon'";
        Restart = "always";
        # Emacs exits with exit code 15 (SIGTERM), when stopped by systemd.
        SuccessExitStatus = 15;
        Type = "notify";
      };

      unitConfig = lib.optionalAttrs cfg.startWithGraphical {
        After = "graphical-session.target";
      };
    }
    // lib.optionalAttrs cfg.enable {
      wantedBy = if cfg.startWithGraphical then [ "graphical-session.target" ] else [ "default.target" ];
    };
  };

  meta.doc = ./emacs.md;
}
