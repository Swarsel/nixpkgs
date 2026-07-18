{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.opengamepadui;
  gamescopeCfg = config.programs.gamescope;

  opengamepadui-gamescope =
    let
      exports = lib.mapAttrsToList (n: v: "export ${n}=${v}") cfg.gamescopeSession.env;
    in
    # Based on gamescope-session-plus from ChimeraOS
    pkgs.writeShellScriptBin "opengamepadui-gamescope" ''
      ${builtins.concatStringsSep "\n" exports}

      # Enable Mangoapp
      export MANGOHUD_CONFIGFILE=$(mktemp /tmp/mangohud.XXXXXXXX)
      export RADV_FORCE_VRS_CONFIG_FILE=$(mktemp /tmp/radv_vrs.XXXXXXXX)

      # Plop GAMESCOPE_MODE_SAVE_FILE into $XDG_CONFIG_HOME (defaults to ~/.config).
      export GAMESCOPE_MODE_SAVE_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/gamescope/modes.cfg"
      export GAMESCOPE_PATCHED_EDID_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/gamescope/edid.bin"

      # Make path to gamescope mode save file.
      mkdir -p "$(dirname "$GAMESCOPE_MODE_SAVE_FILE")"
      touch "$GAMESCOPE_MODE_SAVE_FILE"

      # Make path to Gamescope edid patched file.
      mkdir -p "$(dirname "$GAMESCOPE_PATCHED_EDID_FILE")"
      touch "$GAMESCOPE_PATCHED_EDID_FILE"

      # Initially write no_display to our config file
      # so we don't get mangoapp showing up before OpenGamepadUI initializes
      # on OOBE and stuff.
      mkdir -p "$(dirname "$MANGOHUD_CONFIGFILE")"
      echo "no_display" >"$MANGOHUD_CONFIGFILE"

      # Prepare our initial VRS config file
      # for dynamic VRS in Mesa.
      mkdir -p "$(dirname "$RADV_FORCE_VRS_CONFIG_FILE")"
      echo "1x1" >"$RADV_FORCE_VRS_CONFIG_FILE"

      # To play nice with the short term callback-based limiter for now
      export GAMESCOPE_LIMITER_FILE=$(mktemp /tmp/gamescope-limiter.XXXXXXXX)

      ulimit -n 524288

      # Setup socket for gamescope
      # Create run directory file for startup and stats sockets
      tmpdir="$([[ -n ''${XDG_RUNTIME_DIR+x} ]] && mktemp -p "$XDG_RUNTIME_DIR" -d -t gamescope.XXXXXXX)"
      socket="''${tmpdir:+$tmpdir/startup.socket}"
      stats="''${tmpdir:+$tmpdir/stats.pipe}"

      # Fail early if we don't have a proper runtime directory setup
      if [[ -z $tmpdir || -z ''${XDG_RUNTIME_DIR+x} ]]; then
        echo >&2 "!! Failed to find run directory in which to create stats session sockets (is \$XDG_RUNTIME_DIR set?)"
        exit 0
      fi

      export GAMESCOPE_STATS="$stats"
      mkfifo -- "$stats"
      mkfifo -- "$socket"

      # Start gamescope compositor, log it's output and background it
      echo gamescope ${lib.escapeShellArgs cfg.gamescopeSession.args}  -R $socket -T $stats >"$HOME"/.gamescope-cmd.log
      gamescope ${lib.escapeShellArgs cfg.gamescopeSession.args} -R $socket -T $stats >"$HOME"/.gamescope-stdout.log 2>&1 &
      gamescope_pid="$!"

      if read -r -t 3 response_x_display response_wl_display <>"$socket"; then
        export DISPLAY="$response_x_display"
        export GAMESCOPE_WAYLAND_DISPLAY="$response_wl_display"
        # We're done!
      else
        echo "gamescope failed"
        kill -9 "$gamescope_pid"
        wait -n "$gamescope_pid"
        exit 1
        # Systemd or Session manager will have to restart session
      fi

      # If we have mangoapp binary start it
      if command -v mangoapp >/dev/null; then
        (while true; do
          sleep 1
          mangoapp >"$HOME"/.mangoapp-stdout.log 2>&1
        done) &
      fi

      # Start OpenGamepadUI
      opengamepadui ${lib.escapeShellArgs cfg.args}

      # When the client exits, kill gamescope nicely
      kill $gamescope_pid
    '';

  gamescopeSessionFile =
    (pkgs.writeTextDir "share/wayland-sessions/opengamepadui.desktop" ''
      [Desktop Entry]
      Name=opengamepadui
      Comment=OpenGamepadUI Session
      Exec=${opengamepadui-gamescope}/bin/opengamepadui-gamescope
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "opengamepadui" ];
      });
in
{
  options.programs.opengamepadui = {
    enable = lib.mkEnableOption "opengamepadui";

    package = lib.mkPackageOption pkgs "OpenGamepadUI" {
      default = [ "opengamepadui" ];
    };

    args = lib.mkOption {
      default = [ ];

      description = ''
        Arguments to be passed to OpenGamepadUI
      '';

      type = lib.types.listOf lib.types.str;
    };

    extraPackages = lib.mkOption {
      default = [ ];

      description = ''
        Additional packages to add to the OpenGamepadUI environment.
      '';

      example = lib.literalExpression ''
        with pkgs; [
          gamescope
        ]
      '';

      type = lib.types.listOf lib.types.package;
    };

    fontPackages = lib.mkOption {
      default = config.fonts.packages;
      defaultText = lib.literalExpression "builtins.filter lib.types.package.check config.fonts.packages";

      description = ''
        Font packages to use in OpenGamepadUI.

        Defaults to system fonts, but could be overridden to use other fonts — useful for users who would like to customize CJK fonts used in opengamepadui. According to the [upstream issue](https://github.com/ValveSoftware/opengamepadui-for-linux/issues/10422#issuecomment-1944396010), opengamepadui only follows the per-user fontconfig configuration.
      '';

      example = lib.literalExpression "with pkgs; [ source-han-sans ]";
      type = lib.types.listOf lib.types.package;
    };

    gamescopeSession = lib.mkOption {
      default = { };
      description = "Run a GameScope driven OpenGamepadUI session from your display-manager";

      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "GameScope Session";

          args = lib.mkOption {
            default = [
              "--prefer-output"
              "*,eDP-1"
              "--xwayland-count"
              "2"
              "--default-touch-mode"
              "4"
              "--hide-cursor-delay"
              "3000"
              "--fade-out-duration"
              "200"
              "--steam"
            ];

            description = ''
              Arguments to be passed to GameScope for the session.
            '';

            type = lib.types.listOf lib.types.str;
          };

          env = lib.mkOption {
            default = { };

            description = ''
              Environmental variables to be passed to GameScope for the session.
            '';

            type = lib.types.attrsOf lib.types.str;
          };
        };
      };
    };

    inputplumber.enable = lib.mkEnableOption ''
      Run InputPlumber service for input management and gamepad configuration.
    '';

    powerstation.enable = lib.mkEnableOption ''
      Run PowerStation service for TDP control and performance settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    environment.pathsToLink = [ "/share" ];

    environment.systemPackages = [
      cfg.package
    ]
    ++ lib.optional cfg.gamescopeSession.enable opengamepadui-gamescope;

    hardware.graphics = {
      # this fixes the "glXChooseVisual failed" bug, context: https://github.com/NixOS/nixpkgs/issues/47932
      enable = true;
      enable32Bit = pkgs.stdenv.hostPlatform.isx86_64;
    };

    hardware.steam-hardware.enable = true;
    programs.gamescope.enable = true;
    programs.opengamepadui.extraPackages = cfg.fontPackages;

    programs.opengamepadui.gamescopeSession.env = {
      # This should be used by default by gamescope. Cannot hurt to force it anyway.
      # Reported better framelimiting with this enabled
      ENABLE_GAMESCOPE_WSI = "1";
      # Temporary crutch until dummy plane interactions / etc are figured out
      GAMESCOPE_DISABLE_ASYNC_FLIPS = "1";
      # There is no way to set a color space for an NV12
      # buffer in Wayland. And the color management protocol that is
      # meant to let this happen is missing the color range...
      # So just workaround this with an ENV var that Remote Play Together
      # and Gamescope will use for now.
      GAMESCOPE_NV12_COLORSPACE = "k_EStreamColorspace_BT601";
      # Fix intel color corruption
      # might come with some performance degradation but is better than a corrupted
      # color image
      INTEL_DEBUG = "norbc";
      # Force Qt applications to run under xwayland
      QT_QPA_PLATFORM = "xcb";
      # Some environment variables by default (taken from Deck session)
      SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
      # Workaround older versions of vkd3d-proton setting this
      # too low (desc.BufferCount), resulting in symptoms that are potentially like
      # swapchain starvation.
      VKD3D_SWAPCHAIN_LATENCY_FRAMES = "3";
      # To expose vram info from radv
      WINEDLLOVERRIDES = "dxgi=n";
      mesa_glthread = "true";
      # Don't wait for buffers to idle on the client side before sending them to gamescope
      vk_xwayland_wait_ready = "false";
    };

    security.wrappers = lib.mkIf (cfg.gamescopeSession.enable && gamescopeCfg.capSysNice) {
      # needed or steam plugin fails
      bwrap = {
        group = "root";
        owner = "root";
        setuid = true;
        source = lib.getExe pkgs.bubblewrap;
      };
    };

    services.displayManager.sessionPackages = lib.mkIf cfg.gamescopeSession.enable [
      gamescopeSessionFile
    ];

    services.inputplumber.enable = lib.mkDefault cfg.inputplumber.enable;
    services.pipewire.alsa.support32Bit = config.services.pipewire.alsa.enable;
    services.powerstation.enable = lib.mkDefault cfg.powerstation.enable;
    # optionally enable 32bit pulseaudio support if pulseaudio is enabled
    services.pulseaudio.support32Bit = config.services.pulseaudio.enable;
  };

  meta.maintainers = with lib.maintainers; [ shadowapex ];
}
