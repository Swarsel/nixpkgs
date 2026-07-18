{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.greetd;
  tty = "tty1";
  settingsFormat = pkgs.formats.toml { };
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "greetd"
      "vt"
    ] "The VT is now fixed to VT1.")
  ];

  options.services.greetd = {
    enable = lib.mkEnableOption "greetd, a minimal and flexible login manager daemon";
    package = lib.mkPackageOption pkgs "greetd" { };

    greeterManagesPlymouth = lib.mkOption {
      default = false;

      description = ''
        Don't configure the greetd service to wait for Plymouth to exit.

        Enable this if the greeter you're using can manage Plymouth itself to provide a smoother handoff.
      '';

      internal = true;
      type = lib.types.bool;
    };

    restart = lib.mkOption {
      default = !(cfg.settings ? initial_session);
      defaultText = lib.literalExpression "!(config.services.greetd.settings ? initial_session)";

      description = ''
        Whether to restart greetd when it terminates (e.g. on failure).
        This is usually desirable so a user can always log in, but should be disabled when using 'settings.initial_session' (autologin),
        because every greetd restart will trigger the autologin again.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      description = ''
        greetd configuration ([documentation](https://man.sr.ht/~kennylevinsen/greetd/))
        as a Nix attribute set.
      '';

      example = lib.literalExpression ''
        {
          default_session = {
            command = "''${pkgs.greetd}/bin/agreety --cmd sway";
          };
        }
      '';

      type = settingsFormat.type;
    };

    useTextGreeter = lib.mkOption {
      default = false;

      description = ''
        Whether the greeter uses text-based user interfaces (For example, tuigreet).

        When set to true, some systemd service configuration will be adjusted to avoid systemd boot messages interrupt TUI.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {

    security.pam.services.greetd = {
      allowNullPassword = true;
      enableGnomeKeyring = lib.mkDefault config.services.gnome.gnome-keyring.enable;
      startSession = true;
    };

    # Enable desktop session data
    services.displayManager.enable = lib.mkDefault true;
    services.greetd.settings.default_session.user = lib.mkDefault "greeter";
    services.greetd.settings.terminal.vt = 1;
    systemd.defaultUnit = "graphical.target";
    # This prevents nixos-rebuild from killing greetd by activating getty again
    systemd.services."autovt@${tty}".enable = false;

    systemd.services.greetd = {
      aliases = [ "display-manager.service" ];
      # Don't kill a user session when using nixos-rebuild
      restartIfChanged = false;

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} --config ${settingsFormat.generate "greetd.toml" cfg.settings}";
        # Defaults from greetd upstream configuration
        IgnoreSIGPIPE = false;
        KeyringMode = "shared";
        Restart = lib.mkIf cfg.restart "on-success";
        SendSIGHUP = true;
        TimeoutStopSec = "30s";
        Type = "idle";
      }
      // (lib.optionalAttrs cfg.useTextGreeter {
        # Without this errors will spam on screen
        StandardError = "journal";
        StandardInput = "tty";
        StandardOutput = "tty";
        # Without these bootlogs will spam on screen
        TTYPath = "/dev/tty1";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      });

      unitConfig = {
        After = [
          "systemd-user-sessions.service"
          "getty@${tty}.service"
        ]
        ++ lib.optionals (!cfg.greeterManagesPlymouth) [
          "plymouth-quit-wait.service"
        ];

        Conflicts = [
          "getty@${tty}.service"
        ];

        Wants = [
          "systemd-user-sessions.service"
        ];
      };

      wantedBy = [ "graphical.target" ];
    };

    # Create directories potentially required by supported greeters
    # See https://github.com/NixOS/nixpkgs/issues/248323
    systemd.tmpfiles.rules = [
      "d '/var/cache/tuigreet' - greeter greeter - -"
    ];

    users.groups.greeter = { };

    users.users.greeter = {
      group = "greeter";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ queezle ];
}
