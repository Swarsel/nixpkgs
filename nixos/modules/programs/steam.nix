{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.steam;
  gamescopeCfg = config.programs.gamescope;

  extraCompatPaths = lib.makeSearchPathOutput "steamcompattool" "" cfg.extraCompatPackages;

  steam-gamescope =
    let
      exports = builtins.attrValues (
        builtins.mapAttrs (n: v: "export ${n}=${v}") cfg.gamescopeSession.env
      );
    in
    pkgs.writeShellScriptBin "steam-gamescope" ''
      ${builtins.concatStringsSep "\n" exports}
      gamescope --steam ${toString cfg.gamescopeSession.args} -- steam ${toString cfg.gamescopeSession.steamArgs}
    '';

  gamescopeSessionFile =
    (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
      [Desktop Entry]
      Name=Steam
      Comment=A digital distribution platform
      Exec=${steam-gamescope}/bin/steam-gamescope
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "steam" ];
      });
in
{
  options.programs.steam = {
    enable = lib.mkEnableOption "steam";

    package = lib.mkOption {
      apply =
        steam:
        steam.override (prev: {
          extraEnv =
            (lib.optionalAttrs (cfg.extraCompatPackages != [ ]) {
              STEAM_EXTRA_COMPAT_TOOLS_PATHS = extraCompatPaths;
            })
            // (lib.optionalAttrs cfg.extest.enable {
              LD_PRELOAD = "${pkgs.pkgsi686Linux.extest}/lib/libextest.so";
            })
            // (prev.extraEnv or { });

          extraLibraries =
            pkgs:
            let
              prevLibs = if prev ? extraLibraries then prev.extraLibraries pkgs else [ ];
              additionalLibs =
                with config.hardware.graphics;
                if pkgs.stdenv.hostPlatform.is64bit then
                  [ package ] ++ extraPackages
                else
                  [ package32 ] ++ extraPackages32;
            in
            prevLibs ++ additionalLibs;

          extraPkgs = p: (cfg.extraPackages ++ lib.optionals (prev ? extraPkgs) (prev.extraPkgs p));
        });

      default = pkgs.steam;
      defaultText = lib.literalExpression "pkgs.steam";

      description = ''
        The Steam package to use. Additional libraries are added from the system
        configuration to ensure graphics work properly.

        Use this option to customise the Steam package rather than adding your
        custom Steam to {option}`environment.systemPackages` yourself.
      '';

      example = lib.literalExpression ''
        pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
            OBS_VKCAPTURE = true;
            RADV_TEX_ANISO = 16;
          };
          extraLibraries = p: with p; [
            atk
          ];
        }
      '';

      type = lib.types.package;
    };

    dedicatedServer.openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open ports in the firewall for Source Dedicated Server.
      '';

      type = lib.types.bool;
    };

    extest.enable = lib.mkEnableOption ''
      Load the extest library into Steam, to translate X11 input events to
      uinput events (e.g. for using Steam Input on Wayland)
    '';

    extraCompatPackages = lib.mkOption {
      default = [ ];

      description = ''
        Extra packages to be used as compatibility tools for Steam on Linux. Packages will be included
        in the `STEAM_EXTRA_COMPAT_TOOLS_PATHS` environmental variable. For more information see
        https://github.com/ValveSoftware/steam-for-linux/issues/6310.

        These packages must be Steam compatibility tools that have a `steamcompattool` output.
      '';

      example = lib.literalExpression ''
        with pkgs; [
          proton-ge-bin
        ]
      '';

      type = lib.types.listOf lib.types.package;
    };

    extraPackages = lib.mkOption {
      default = [ ];

      description = ''
        Additional packages to add to the Steam environment.
      '';

      example = lib.literalExpression ''
        with pkgs; [
          gamescope
        ]
      '';

      type = lib.types.listOf lib.types.package;
    };

    fontPackages = lib.mkOption {
      # `fonts.packages` is a list of paths now, filter out which are not packages
      default = builtins.filter lib.types.package.check config.fonts.packages;
      defaultText = lib.literalExpression "builtins.filter lib.types.package.check config.fonts.packages";

      description = ''
        Font packages to use in Steam.

        Defaults to system fonts, but could be overridden to use other fonts — useful for users who would like to customize CJK fonts used in Steam. According to the [upstream issue](https://github.com/ValveSoftware/steam-for-linux/issues/10422#issuecomment-1944396010), Steam only follows the per-user fontconfig configuration.
      '';

      example = lib.literalExpression "with pkgs; [ source-han-sans ]";
      type = lib.types.listOf lib.types.package;
    };

    gamescopeSession = lib.mkOption {
      default = { };
      description = "Run a GameScope driven Steam session from your display-manager";

      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "GameScope Session";

          args = lib.mkOption {
            default = [ ];

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

          steamArgs = lib.mkOption {
            default = [
              "-tenfoot"
              "-pipewire-dmabuf"
            ];

            description = ''
              Arguments to be passed to Steam for the session.
            '';

            type = lib.types.listOf lib.types.str;
          };
        };
      };
    };

    localNetworkGameTransfers.openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open ports in the firewall for Steam Local Network Game Transfers.
      '';

      type = lib.types.bool;
    };

    protontricks = {
      enable = lib.mkEnableOption "protontricks, a simple wrapper for running Winetricks commands for Proton-enabled games";
      package = lib.mkPackageOption pkgs "protontricks" { };
    };

    remotePlay.openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open ports in the firewall for Steam Remote Play.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      cfg.package.run
    ]
    ++ lib.optional cfg.gamescopeSession.enable steam-gamescope
    ++ lib.optional cfg.protontricks.enable (
      cfg.protontricks.package.override { inherit extraCompatPaths; }
    );

    hardware.graphics = {
      # this fixes the "glXChooseVisual failed" bug, context: https://github.com/NixOS/nixpkgs/issues/47932
      enable = true;
      enable32Bit = true;
    };

    hardware.steam-hardware.enable = true;

    networking.firewall = lib.mkMerge [
      (lib.mkIf (cfg.remotePlay.openFirewall || cfg.localNetworkGameTransfers.openFirewall) {
        allowedUDPPorts = [ 27036 ]; # Peer discovery
      })

      (lib.mkIf cfg.remotePlay.openFirewall {
        # https://help.steampowered.com/en/faqs/view/3E3D-BE6B-787D-A5D2
        # https://help.steampowered.com/en/faqs/view/2EA8-4D75-DA21-31EB
        allowedTCPPorts = [
          27036
          27037
        ];

        allowedUDPPortRanges = [
          {
            from = 27031;
            to = 27035;
          }
        ];

        allowedUDPPorts = [
          10400
          10401
        ];
      })

      (lib.mkIf cfg.dedicatedServer.openFirewall {
        allowedTCPPorts = [ 27015 ]; # SRCDS Rcon port
        allowedUDPPorts = [ 27015 ]; # Gameplay traffic
      })

      (lib.mkIf cfg.localNetworkGameTransfers.openFirewall {
        allowedTCPPorts = [ 27040 ]; # Data transfers
      })
    ];

    programs.gamescope.enable = lib.mkDefault cfg.gamescopeSession.enable;
    programs.steam.extraPackages = cfg.fontPackages;

    services.displayManager.sessionPackages = lib.mkIf cfg.gamescopeSession.enable [
      gamescopeSessionFile
    ];

    services.pipewire.alsa.support32Bit = config.services.pipewire.alsa.enable;
    # enable 32bit pulseaudio/pipewire support if needed
    services.pulseaudio.support32Bit = config.services.pulseaudio.enable;
  };

  meta.teams = [ lib.teams.steam ];
}
