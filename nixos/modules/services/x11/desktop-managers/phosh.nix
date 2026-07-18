{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.xserver.desktopManager.phosh;

  phocConfigType = lib.types.submodule {
    options = {
      cursorTheme = lib.mkOption {
        default = "default";

        description = ''
          Cursor theme to use in Phosh.
        '';

        type = lib.types.str;
      };

      outputs = lib.mkOption {
        default = {
          DSI-1 = {
            scale = 2;
          };
        };

        description = ''
          Output configurations.
        '';

        type = lib.types.attrsOf phocOutputType;
      };

      xwayland = lib.mkOption {
        default = "false";

        description = ''
          Whether to enable XWayland support.

          To start XWayland immediately, use `immediate`.
        '';

        type = lib.types.enum [
          "true"
          "false"
          "immediate"
        ];
      };
    };
  };

  phocOutputType = lib.types.submodule {
    options = {
      mode = lib.mkOption {
        default = null;

        description = ''
          Default video mode.
        '';

        example = "768x1024";
        type = lib.types.nullOr lib.types.str;
      };

      modeline = lib.mkOption {
        default = [ ];

        description = ''
          One or more modelines.
        '';

        example = [
          "87.25 720 776 848  976 1440 1443 1453 1493 -hsync +vsync"
          "65.13 768 816 896 1024 1024 1025 1028 1060 -HSync +VSync"
        ];

        type = lib.types.either lib.types.str (lib.types.listOf lib.types.str);
      };

      rotate = lib.mkOption {
        default = null;

        description = ''
          Screen transformation.
        '';

        type = lib.types.enum [
          "90"
          "180"
          "270"
          "flipped"
          "flipped-90"
          "flipped-180"
          "flipped-270"
          null
        ];
      };

      scale = lib.mkOption {
        default = null;

        description = ''
          Display scaling factor.
        '';

        example = 2;

        type =
          lib.types.nullOr (lib.types.addCheck (lib.types.either lib.types.int lib.types.float) (x: x > 0))
          // {
            description = "null or positive integer or float";
          };
      };
    };
  };

  optionalKV = k: v: lib.optionalString (v != null) "${k} = ${toString v}";

  renderPhocOutput =
    name: output:
    let
      modelines = if builtins.isList output.modeline then output.modeline else [ output.modeline ];
      renderModeline = l: "modeline = ${l}";
    in
    ''
      [output:${name}]
      ${lib.concatStringsSep "\n" (map renderModeline modelines)}
      ${optionalKV "mode" output.mode}
      ${optionalKV "scale" output.scale}
      ${optionalKV "rotate" output.rotate}
    '';

  renderPhocConfig =
    phoc:
    let
      outputs = lib.mapAttrsToList renderPhocOutput phoc.outputs;
    in
    ''
      [core]
      xwayland = ${phoc.xwayland}
      ${lib.concatStringsSep "\n" outputs}
      [cursor]
      theme = ${phoc.cursorTheme}
    '';
in

{

  options = {
    services.xserver.desktopManager.phosh = {
      enable = lib.mkOption {
        default = false;
        description = "Enable the Phone Shell.";
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "phosh" { };

      group = lib.mkOption {
        description = "The group to run the Phosh service.";
        example = "users";
        type = lib.types.str;
      };

      phocConfig = lib.mkOption {
        default = { };

        description = ''
          Configurations for the Phoc compositor.
        '';

        type = lib.types.oneOf [
          lib.types.lines
          lib.types.path
          phocConfigType
        ];
      };

      user = lib.mkOption {
        description = "The user to run the Phosh service.";
        example = "alice";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."phosh/phoc.ini".source =
      if builtins.isPath cfg.phocConfig then
        cfg.phocConfig
      else if builtins.isString cfg.phocConfig then
        pkgs.writeText "phoc.ini" cfg.phocConfig
      else
        pkgs.writeText "phoc.ini" (renderPhocConfig cfg.phocConfig);

    environment.systemPackages = [
      pkgs.phoc
      cfg.package
      pkgs.stevia
    ];

    programs.feedbackd.enable = true;
    security.pam.services.phosh = { };
    services.displayManager.sessionPackages = [ cfg.package ];
    services.gnome.core-os-services.enable = true;
    services.gnome.core-shell.enable = true;
    services.graphical-desktop.enable = true;
    systemd.packages = [ cfg.package ];

    # Inspired by https://gitlab.gnome.org/World/Phosh/phosh/-/blob/main/data/phosh.service
    # Parts taken from nixos/modules/services/wayland/cage.nix
    systemd.services.phosh = {
      after = [ "getty@tty1.service" ];
      conflicts = [ "getty@tty1.service" ];

      environment = {
        # We are running without a display manager, so need to provide
        # a value for XDG_CURRENT_DESKTOP.
        #
        # Among other things, this variable influences:
        #  - visibility of desktop entries with "OnlyShowIn=Phosh;"
        #    https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-1.5.html#key-onlyshowin
        #  - the chosen xdg-desktop-portal configuration.
        #    https://flatpak.github.io/xdg-desktop-portal/docs/portals.conf.html
        XDG_CURRENT_DESKTOP = "Phosh:GNOME";
        # pam_systemd uses these to identify the session in logind.
        # https://www.freedesktop.org/software/systemd/man/latest/pam_systemd.html#desktop=
        XDG_SESSION_DESKTOP = "phosh";
        XDG_SESSION_TYPE = "wayland";
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/phosh-session";
        Group = cfg.group;
        PAMName = "login";
        Restart = "always";
        StandardError = "journal";
        # Fail to start if not controlling the tty.
        StandardInput = "tty-fail";
        StandardOutput = "journal";
        TTYPath = "/dev/tty1";
        TTYReset = "yes";
        TTYVHangup = "yes";
        TTYVTDisallocate = "yes";
        User = cfg.user;
        # Log this user with utmp, letting it show up with commands 'w' and 'who'.
        UtmpIdentifier = "tty1";
        UtmpMode = "user";
        WorkingDirectory = "~";
      };

      wantedBy = [ "graphical.target" ];
    };

    xdg.portal = {
      enable = true;
      configPackages = lib.mkDefault [ pkgs.phosh ];

      extraPortals = [
        pkgs.xdg-desktop-portal-phosh
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ armelclo ];
  };
}
