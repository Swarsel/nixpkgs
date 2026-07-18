{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let

  # Abbreviations.
  cfg = config.services.xserver;

  knownVideoDriverPackages = {
    inherit (pkgs)
      xf86-video-amdgpu
      xf86-video-apm
      xf86-video-ark
      xf86-video-ast
      xf86-video-ati
      xf86-video-chips
      xf86-video-cirrus
      xf86-video-dummy
      xf86-video-fbdev
      xf86-video-geode
      xf86-video-i128
      xf86-video-i740
      xf86-video-intel
      xf86-video-mga
      xf86-video-neomagic
      xf86-video-nested
      xf86-video-nouveau
      xf86-video-nv
      xf86-video-omap
      xf86-video-openchrome
      xf86-video-qxl
      xf86-video-r128
      xf86-video-s3virge
      xf86-video-savage
      xf86-video-siliconmotion
      xf86-video-sis
      xf86-video-sisusb
      xf86-video-suncg6
      xf86-video-sunffb
      xf86-video-sunleo
      xf86-video-tdfx
      xf86-video-trident
      xf86-video-v4l
      xf86-video-vbox
      xf86-video-vesa
      xf86-video-vmware
      xf86-video-voodoo
      ;
  };

  # Map video driver names to driver packages. FIXME: move into card-specific modules.
  videoDrivers =
    mapAttrs' (name: value: {
      name = removePrefix "xf86-video-" value.pname;

      value = {
        modules = [ value ];
      };
    }) knownVideoDriverPackages
    // videoDriverAliases
    // videoDriverOverrides;

  videoDriverOverrides = {
    # Override the driver name of vbox is "vboxvideo".
    vbox = {
      driverName = "vboxvideo";
      modules = [ knownVideoDriverPackages.xf86-video-vbox ];
    };
  };

  videoDriverAliases = {
    # modesetting does not have a xf86-video-modesetting package as it is included in xorg-server
    modesetting = { };

    # Alias so that "radeon" uses the xf86-video-ati driver.
    radeon = {
      driverName = "ati";
      modules = [ knownVideoDriverPackages.xf86-video-ati ];
    };

    # Alias so people can keep using "vboxvideo" instead of "vbox".
    vboxvideo = {
      driverName = "vboxvideo";
      modules = [ knownVideoDriverPackages.xf86-video-vbox ];
    };

    # Alias so people can keep using "virtualbox" instead of "vboxvideo".
    virtualbox = {
      driverName = "vboxvideo";
      modules = [ knownVideoDriverPackages.xf86-video-vbox ];
    };
  };

  fontsForXServer =
    config.fonts.packages
    ++
    # We don't want these fonts in fonts.conf, because then modern,
    # fontconfig-based applications will get horrible bitmapped
    # Helvetica fonts.  It's better to get a substitution (like Nimbus
    # Sans) than that horror.  But we do need the Adobe fonts for some
    # old non-fontconfig applications.  (Possibly this could be done
    # better using a fontconfig rule.)
    [
      pkgs.font-adobe-100dpi
      pkgs.font-adobe-75dpi
    ];

  xrandrOptions = {
    monitorConfig = mkOption {
      default = "";

      description = ''
        Extra lines to append to the `Monitor` section
        verbatim. Available options are documented in the MONITOR section in
        {manpage}`xorg.conf(5)`.
      '';

      example = ''
        DisplaySize 408 306
        Option "DPMS" "false"
      '';

      type = types.lines;
    };

    output = mkOption {
      description = ''
        The output name of the monitor, as shown by
        {manpage}`xrandr(1)` invoked without arguments.
      '';

      example = "DVI-0";
      type = types.str;
    };

    primary = mkOption {
      default = false;

      description = ''
        Whether this head is treated as the primary monitor,
      '';

      type = types.bool;
    };
  };

  # Just enumerate all heads without discarding XRandR output information.
  xrandrHeads =
    let
      mkHead = num: config: {
        inherit config;
        name = "multihead${toString num}";
      };
    in
    imap1 mkHead cfg.xrandrHeads;

  xrandrDeviceSection =
    let
      monitors = forEach xrandrHeads (h: ''
        Option "monitor-${h.config.output}" "${h.name}"
      '');
    in
    concatStrings monitors;

  # Here we chain every monitor from the left to right, so we have:
  # m4 right of m3 right of m2 right of m1   .----.----.----.----.
  # Which will end up in reverse ----------> | m1 | m2 | m3 | m4 |
  #                                          `----^----^----^----'
  xrandrMonitorSections =
    let
      mkMonitor =
        previous: current:
        singleton {
          inherit (current) name;

          value = ''
            Section "Monitor"
              Identifier "${current.name}"
              ${optionalString (current.config.primary) ''
                Option "Primary" "true"
              ''}
              ${optionalString (previous != [ ]) ''
                Option "RightOf" "${(head previous).name}"
              ''}
              ${current.config.monitorConfig}
            EndSection
          '';
        }
        ++ previous;
      monitors = reverseList (foldl mkMonitor [ ] xrandrHeads);
    in
    concatMapStrings (getAttr "value") monitors;

  configFile =
    pkgs.runCommand "xserver.conf"
      {
        inherit (cfg) config;
        fontpath = optionalString (cfg.fontPath != null) ''FontPath "${cfg.fontPath}"'';
        preferLocalBuild = true;
      }
      ''
        echo 'Section "Files"' >> $out
        echo "$fontpath" >> $out

        for i in ${toString fontsForXServer}; do
          if test "''${i:0:''${#NIX_STORE}}" == "$NIX_STORE"; then
            for j in $(find $i -name fonts.dir); do
              echo "  FontPath \"$(dirname $j)\"" >> $out
            done
          fi
        done

        ${concatMapStrings (m: ''
          echo "  ModulePath \"${m}/lib/xorg/modules\"" >> "$out"
        '') cfg.modules}

        echo '${cfg.filesSection}' >> $out
        echo 'EndSection' >> $out
        echo >> $out

        echo "$config" >> $out
      ''; # */

  prefixStringLines =
    prefix: str: concatMapStringsSep "\n" (line: prefix + line) (splitString "\n" str);

  indent = prefixStringLines "  ";

  # A scalable variant of the X11 "core" cursor
  #
  # If not running a fancy desktop environment, the cursor is likely set to
  # the default `cursor.pcf` bitmap font. This is 17px wide, so it's very
  # small and almost invisible on 4K displays.
  fontcursormisc_hidpi = pkgs.font-xfree86-type1.overrideAttrs (
    old:
    let
      # The scaling constant is 230/96: the scalable `left_ptr` glyph at
      # about 23 points is rendered as 17px, on a 96dpi display.
      # Note: the XLFD font size is in decipoints.
      size = 2.39583 * cfg.dpi;
      sizeString = builtins.head (builtins.split "\\." (toString size));
    in
    {
      postInstall = ''
        alias='cursor -xfree86-cursor-medium-r-normal--0-${sizeString}-0-0-p-0-adobe-fontspecific'
        echo "$alias" > $out/share/fonts/X11/Type1/fonts.alias
      '';
    }
  );
in

{

  imports = [
    ./display-managers/default.nix
    ./window-managers/default.nix
    ./desktop-managers/default.nix
    (mkRemovedOptionModule [
      "services"
      "xserver"
      "startGnuPGAgent"
    ] "See the 16.09 release notes for more information.")
    (mkRemovedOptionModule [
      "services"
      "xserver"
      "startDbusSession"
    ] "The user D-Bus session is now always socket activated and this option can safely be removed.")
    (mkRemovedOptionModule [
      "services"
      "xserver"
      "useXFS"
    ] "Use services.xserver.fontPath instead of useXFS")
    (mkRemovedOptionModule [ "services" "xserver" "useGlamor" ]
      "Option services.xserver.useGlamor was removed because it is unnecessary. Drivers that uses Glamor will use it automatically."
    )
    (lib.mkRenamedOptionModuleWith {
      from = [
        "services"
        "xserver"
        "layout"
      ];

      sinceRelease = 2311;

      to = [
        "services"
        "xserver"
        "xkb"
        "layout"
      ];
    })
    (lib.mkRenamedOptionModuleWith {
      from = [
        "services"
        "xserver"
        "xkbModel"
      ];

      sinceRelease = 2311;

      to = [
        "services"
        "xserver"
        "xkb"
        "model"
      ];
    })
    (lib.mkRenamedOptionModuleWith {
      from = [
        "services"
        "xserver"
        "xkbOptions"
      ];

      sinceRelease = 2311;

      to = [
        "services"
        "xserver"
        "xkb"
        "options"
      ];
    })
    (lib.mkRenamedOptionModuleWith {
      from = [
        "services"
        "xserver"
        "xkbVariant"
      ];

      sinceRelease = 2311;

      to = [
        "services"
        "xserver"
        "xkb"
        "variant"
      ];
    })
    (lib.mkRenamedOptionModuleWith {
      from = [
        "services"
        "xserver"
        "xkbDir"
      ];

      sinceRelease = 2311;

      to = [
        "services"
        "xserver"
        "xkb"
        "dir"
      ];
    })
    (lib.mkRemovedOptionModule [
      "services"
      "xserver"
      "tty"
    ] "'services.xserver.tty' was removed because it was ineffective.")
  ];

  ###### interface

  options = {

    services.xserver = {

      config = mkOption {
        description = ''
          The contents of the configuration file of the X server
          ({file}`xorg.conf`).

          This option is set by multiple modules, and the configs are
          concatenated together.

          In Xorg configs the last config entries take precedence,
          so you may want to use `lib.mkAfter` on this option
          to override NixOS's defaults.
        '';

        type = types.lines;
      };

      enable = mkOption {
        default = false;

        description = ''
          Whether to enable the X server.
        '';

        type = types.bool;
      };

      autoRepeatDelay = mkOption {
        default = null;

        description = ''
          Sets the autorepeat delay (length of time in milliseconds that a key must be depressed before autorepeat starts).
        '';

        type = types.nullOr types.int;
      };

      autoRepeatInterval = mkOption {
        default = null;

        description = ''
          Sets the autorepeat interval (length of time in milliseconds that should elapse between autorepeat-generated keystrokes).
        '';

        type = types.nullOr types.int;
      };

      autorun = mkOption {
        default = true;

        description = ''
          Whether to start the X server automatically.
        '';

        type = types.bool;
      };

      defaultDepth = mkOption {
        default = 0;
        description = "Default colour depth.";
        example = 8;
        type = types.int;
      };

      deviceSection = mkOption {
        default = "";
        description = "Contents of the first Device section of the X server configuration file.";
        example = "VideoRAM 131072";
        type = types.lines;
      };

      display = mkOption {
        default = 0;
        description = "Display number for the X server.";
        type = types.nullOr types.int;
      };

      dpi = mkOption {
        default = null;

        description = ''
          Force global DPI resolution to use for X server. It's recommended to
          use this only when DPI is detected incorrectly; also consider using
          `Monitor` section in configuration file instead.
        '';

        type = types.nullOr types.int;
      };

      drivers = mkOption {
        description = ''
          A list of attribute sets specifying drivers to be loaded by
          the X11 server. This module will create a Device section in
          the Xorg config for every driver listed here, along with a
          Screen section if the driver's {option}`display` attribute is
          `true`. If such configuration sections should not be created,
          use {options}`services.xserver.externallyConfiguredDrivers`
          instead.

          Users should not add drivers to this option but should instead
          add drivers to {option}`services.xserver.videoDrivers`.
        '';

        internal = true;
        type = types.listOf types.attrs;
      };

      enableCtrlAltBackspace = mkOption {
        default = false;

        description = ''
          Whether to enable the DontZap option, which binds Ctrl+Alt+Backspace
          to forcefully kill X. This can lead to data loss and is disabled
          by default.
        '';

        type = types.bool;
      };

      enableTCP = mkOption {
        default = false;

        description = ''
          Whether to allow the X server to accept TCP connections.
        '';

        type = types.bool;
      };

      enableTearFree = mkEnableOption "the TearFree option in the first Device section";

      excludePackages = mkOption {
        default = [ ];
        description = "Which X11 packages to exclude from the default environment";
        example = literalExpression "[ pkgs.xterm ]";
        type = types.listOf types.package;
      };

      exportConfiguration = mkOption {
        default = false;

        description = ''
          Whether to symlink the X server configuration under
          {file}`/etc/X11/xorg.conf`.
        '';

        type = types.bool;
      };

      externallyConfiguredDrivers = mkOption {
        default = [ ];

        description = ''
          A list of externally configured drivers (by name). Modules that
          manually configure their drivers should add said drivers to this
          list to let this module know that the driver has been configured.
        '';

        internal = true;
        type = types.listOf types.str;
      };

      extraConfig = mkOption {
        default = "";
        description = "Additional contents (sections) included in the X server configuration file";
        type = types.lines;
      };

      extraDisplaySettings = mkOption {
        default = "";
        description = "Lines to be added to every Display subsection of the Screen section.";
        example = "Virtual 2048 2048";
        type = types.lines;
      };

      filesSection = mkOption {
        default = "";
        description = "Contents of the first `Files` section of the X server configuration file.";
        example = ''FontPath "/path/to/my/fonts"'';
        type = types.lines;
      };

      fontPath = mkOption {
        default = null;

        description = ''
          Set the X server FontPath. Defaults to null, which
          means the compiled in defaults will be used. See
          man xorg.conf for details.
        '';

        example = "unix/:7100";
        type = types.nullOr types.str;
      };

      inputClassSections = mkOption {
        default = [ ];
        description = "Content of additional InputClass sections of the X server configuration file.";

        example = literalExpression ''
          [ '''
              Identifier      "Trackpoint Wheel Emulation"
              MatchProduct    "ThinkPad USB Keyboard with TrackPoint"
              Option          "EmulateWheel"          "true"
              Option          "EmulateWheelButton"    "2"
              Option          "Emulate3Buttons"       "false"
            '''
          ]
        '';

        type = types.listOf types.lines;
      };

      logFile = mkOption {
        default = "/dev/null";

        description = ''
          Controls the file Xorg logs to.

          The default of `/dev/null` is set so that systemd services (like `displayManagers`) only log to the journal and don't create their own log files.

          Setting this to `null` will not pass the `-logfile` argument to Xorg which allows it to log to its default logfile locations instead (see `man Xorg`). You probably only want this behaviour when running Xorg manually (e.g. via `startx`).
        '';

        example = "/var/log/Xorg.0.log";
        type = types.nullOr types.str;
      };

      moduleSection = mkOption {
        default = "";
        description = "Contents of the Module section of the X server configuration file.";

        example = ''
          SubSection "extmod"
          EndSubsection
        '';

        type = types.lines;
      };

      modules = mkOption {
        default = [ ];
        description = "Packages to be added to the module search path of the X server.";
        example = literalExpression "[ pkgs.xf86-input-wacom ]";
        type = types.listOf types.path;
      };

      monitorSection = mkOption {
        default = "";
        description = "Contents of the first Monitor section of the X server configuration file.";
        example = "HorizSync 28-49";
        type = types.lines;
      };

      resolutions = mkOption {
        default = [ ];

        description = ''
          The screen resolutions for the X server.  The first element
          is the default resolution.  If this list is empty, the X
          server will automatically configure the resolution.
        '';

        example = [
          {
            x = 1600;
            y = 1200;
          }
          {
            x = 1024;
            y = 786;
          }
        ];

        type = types.listOf types.attrs;
      };

      screenSection = mkOption {
        default = "";
        description = "Contents of the first Screen section of the X server configuration file.";

        example = ''
          Option "RandRRotation" "on"
        '';

        type = types.lines;
      };

      serverFlagsSection = mkOption {
        default = "";
        description = "Contents of the ServerFlags section of the X server configuration file.";

        example = ''
          Option "BlankTime" "0"
          Option "StandbyTime" "0"
          Option "SuspendTime" "0"
          Option "OffTime" "0"
        '';

        type = types.lines;
      };

      serverLayoutSection = mkOption {
        default = "";
        description = "Contents of the ServerLayout section of the X server configuration file.";

        example = ''
          Option "AIGLX" "true"
        '';

        type = types.lines;
      };

      terminateOnReset = mkOption {
        default = true;

        description = ''
          Whether to terminate X upon server reset.
        '';

        type = types.bool;
      };

      updateDbusEnvironment = mkOption {
        default = false;

        description = ''
          Whether to update the DBus activation environment after launching the
          desktop manager.
        '';

        type = types.bool;
      };

      upscaleDefaultCursor = mkOption {
        default = false;

        description = ''
          Upscale the default X cursor to be more visible on high-density displays.
          Requires `config.services.xserver.dpi` to be set.
        '';

        type = types.bool;
      };

      verbose = mkOption {
        default = 3;

        description = ''
          Controls verbosity of X logging.
        '';

        example = 7;
        type = types.nullOr types.int;
      };

      videoDriver = mkOption {
        default = null;

        description = ''
          The name of the video driver for your graphics card.  This
          option is obsolete; please set the
          {option}`services.xserver.videoDrivers` instead.
        '';

        example = "i810";
        type = types.nullOr types.str;
      };

      videoDrivers = mkOption {
        default = [
          "modesetting"
          "fbdev"
        ];

        description = ''
          The names of the video drivers the configuration
          supports. They will be tried in order until one that
          supports your card is found.
          Don't combine those with "incompatible" OpenGL implementations,
          e.g. free ones (mesa-based) with proprietary ones.

          For unfree "nvidia*", the supported GPU lists are on
          https://www.nvidia.com/object/unix.html
        '';

        example = [
          "nvidia"
          "amdgpu"
        ];

        relatedPackages = mapAttrsToList (name: value: {
          path = [ name ];
          title = removePrefix "xf86-video-" value.pname;
        }) knownVideoDriverPackages;

        type = types.listOf types.str;
      };

      virtualScreen = mkOption {
        default = null;

        description = ''
          Virtual screen size for Xrandr.
        '';

        example = {
          x = 2048;
          y = 2048;
        };

        type = types.nullOr types.attrs;
      };

      xkb = {
        options = mkOption {
          default = "terminate:ctrl_alt_bksp";

          description = ''
            X keyboard options; layout switching goes here.
          '';

          example = "grp:caps_toggle,grp_led:scroll";
          type = types.commas;
        };

        dir = mkOption {
          default = "${pkgs.xkeyboard_config}/etc/X11/xkb";
          defaultText = literalExpression ''"''${pkgs.xkeyboard_config}/etc/X11/xkb"'';

          description = ''
            Path used for -xkbdir xserver parameter.
          '';

          type = types.path;
        };

        layout = mkOption {
          default = "us";

          description = ''
            X keyboard layout, or multiple keyboard layouts separated by commas.
          '';

          type = types.str;
        };

        model = mkOption {
          default = "pc104";

          description = ''
            X keyboard model.
          '';

          example = "presario";
          type = types.str;
        };

        variant = mkOption {
          default = "";

          description = ''
            X keyboard variant.
          '';

          example = "colemak";
          type = types.str;
        };
      };

      xrandrHeads = mkOption {
        # Set primary to true for the first head if no other has been set
        # primary already.
        apply =
          heads:
          let
            hasPrimary = any (x: x.primary) heads;
            firstPrimary = head heads // {
              primary = true;
            };
            newHeads = singleton firstPrimary ++ tail heads;
          in
          if heads != [ ] && !hasPrimary then newHeads else heads;

        default = [ ];

        description = ''
          Multiple monitor configuration, just specify a list of XRandR
          outputs. The individual elements should be either simple strings or
          an attribute set of output options.

          If the element is a string, it is denoting the physical output for a
          monitor, if it's an attribute set, you must at least provide the
          {option}`output` option.

          The monitors will be mapped from left to right in the order of the
          list.

          By default, the first monitor will be set as the primary monitor if
          none of the elements contain an option that has set
          {option}`primary` to `true`.

          ::: {.note}
          Only one monitor is allowed to be primary.
          :::

          Be careful using this option with multiple graphic adapters or with
          drivers that have poor support for XRandR, unexpected things might
          happen with those.
        '';

        example = [
          "HDMI-0"
          {
            output = "DVI-0";
            primary = true;
          }
          {
            monitorConfig = "Option \"Rotate\" \"left\"";
            output = "DVI-1";
          }
        ];

        type =
          with types;
          listOf (
            coercedTo str
              (output: {
                inherit output;
              })
              (submodule {
                options = xrandrOptions;
              })
          );
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = [
      (
        let
          primaryHeads = filter (x: x.primary) cfg.xrandrHeads;
        in
        {
          assertion = length primaryHeads < 2;

          message =
            "Only one head is allowed to be primary in "
            + "‘services.xserver.xrandrHeads’, but there are "
            + "${toString (length primaryHeads)} heads set to primary: "
            + concatMapStringsSep ", " (x: x.output) primaryHeads;
        }
      )
      {
        assertion = cfg.upscaleDefaultCursor -> cfg.dpi != null;
        message = "Specify `config.services.xserver.dpi` to upscale the default cursor.";
      }
    ]
    ++ map (driver: {
      assertion = builtins.elem driver (
        (builtins.catAttrs "name" cfg.drivers) ++ cfg.externallyConfiguredDrivers
      );

      message = "Unknown X11 driver ‘${driver}’ specified in `services.xserver.videoDrivers`.";
    }) cfg.videoDrivers;

    environment.etc =
      (optionalAttrs cfg.exportConfiguration {
        # -xkbdir command line option does not seems to be passed to xkbcomp.
        "X11/xkb".source = "${cfg.xkb.dir}";
        "X11/xorg.conf".source = "${configFile}";
      })
      # Needed since 1.18; see https://bugs.freedesktop.org/show_bug.cgi?id=89023#c5
      // (
        let
          cfgPath = "X11/xorg.conf.d/10-evdev.conf";
        in
        {
          ${cfgPath}.source = pkgs.xf86-input-evdev.out + "/share/" + cfgPath;
        }
      );

    environment.pathsToLink = [ "/share/X11" ];

    environment.systemPackages =
      utils.removePackagesByName [
        pkgs.xorg-server.out
        pkgs.xrandr
        pkgs.xrdb
        pkgs.setxkbmap
        pkgs.iceauth # required for KDE applications (it's called by dcopserver)
        pkgs.xlsclients
        pkgs.xset
        pkgs.xsetroot
        pkgs.xinput
        pkgs.xprop
        pkgs.xauth
        pkgs.xterm
        pkgs.xf86-input-evdev.out # get evdev.4 man page
      ] config.services.xserver.excludePackages
      ++ optional (elem "virtualbox" cfg.videoDrivers) pkgs.xrefresh;

    fonts.packages = [
      (if cfg.upscaleDefaultCursor then fontcursormisc_hidpi else pkgs.font-cursor-misc)
      pkgs.font-misc-misc
      pkgs.font-alias
    ];

    # FIXME: what
    services.displayManager.generic.preStart = ''
      rm -f /tmp/.X0-lock
    '';

    services.xserver.config = ''
      Section "ServerFlags"
        Option "AllowMouseOpenFail" "on"
        Option "DontZap" "${if cfg.enableCtrlAltBackspace then "off" else "on"}"
      ${indent cfg.serverFlagsSection}
      EndSection

      Section "Module"
      ${indent cfg.moduleSection}
      EndSection

      Section "Monitor"
        Identifier "Monitor[0]"
      ${indent cfg.monitorSection}
      EndSection

      # Additional "InputClass" sections
      ${flip (concatMapStringsSep "\n") cfg.inputClassSections (inputClassSection: ''
        Section "InputClass"
        ${indent inputClassSection}
        EndSection
      '')}


      Section "ServerLayout"
        Identifier "Layout[all]"
      ${indent cfg.serverLayoutSection}
        # Reference the Screen sections for each driver.  This will
        # cause the X server to try each in turn.
        ${flip concatMapStrings (filter (d: d.display) cfg.drivers) (d: ''
          Screen "Screen-${d.name}[0]"
        '')}
      EndSection

      # For each supported driver, add a "Device" and "Screen"
      # section.
      ${flip concatMapStrings cfg.drivers (driver: ''

        Section "Device"
          Identifier "Device-${driver.name}[0]"
          Driver "${driver.driverName or driver.name}"
        ${indent (optionalString cfg.enableTearFree ''Option "TearFree" "true"'')}
        ${indent cfg.deviceSection}
        ${indent (driver.deviceSection or "")}
        ${indent xrandrDeviceSection}
        EndSection
        ${optionalString driver.display ''

          Section "Screen"
            Identifier "Screen-${driver.name}[0]"
            Device "Device-${driver.name}[0]"
            ${optionalString (cfg.monitorSection != "") ''
              Monitor "Monitor[0]"
            ''}

          ${indent cfg.screenSection}
          ${indent (driver.screenSection or "")}

            ${optionalString (cfg.defaultDepth != 0) ''
              DefaultDepth ${toString cfg.defaultDepth}
            ''}

            ${optionalString
              (
                driver.name != "virtualbox"
                && (cfg.resolutions != [ ] || cfg.extraDisplaySettings != "" || cfg.virtualScreen != null)
              )
              (
                let
                  f = depth: ''
                    SubSection "Display"
                      Depth ${toString depth}
                      ${optionalString (cfg.resolutions != [ ])
                        "Modes ${concatMapStrings (res: ''"${toString res.x}x${toString res.y}"'') cfg.resolutions}"
                      }
                    ${indent cfg.extraDisplaySettings}
                      ${optionalString (
                        cfg.virtualScreen != null
                      ) "Virtual ${toString cfg.virtualScreen.x} ${toString cfg.virtualScreen.y}"}
                    EndSubSection
                  '';
                in
                concatMapStrings f [
                  8
                  16
                  24
                ]
              )
            }

          EndSection
        ''}
      '')}

      ${xrandrMonitorSections}

      ${cfg.extraConfig}
    '';

    services.xserver.displayManager.lightdm.enable =
      let
        dmConf = cfg.displayManager;
        default =
          !(
            config.services.displayManager.gdm.enable
            || config.services.displayManager.sddm.enable
            || dmConf.xpra.enable
            || dmConf.sx.enable
            || dmConf.startx.enable
            || config.services.greetd.enable
            || config.services.displayManager.ly.enable
            || config.services.displayManager.lemurs.enable
            || config.services.displayManager.plasma-login-manager.enable
          );
      in
      mkIf default (mkDefault true);

    services.xserver.displayManager.xserverArgs = [
      "-config ${configFile}"
      "-xkbdir"
      "${cfg.xkb.dir}"
    ]
    ++ optional (cfg.display != null) ":${toString cfg.display}"
    ++ optional (cfg.dpi != null) "-dpi ${toString cfg.dpi}"
    ++ optional (cfg.logFile != null) "-logfile ${toString cfg.logFile}"
    ++ optional (cfg.verbose != null) "-verbose ${toString cfg.verbose}"
    ++ optional (!cfg.enableTCP) "-nolisten tcp"
    ++ optional (cfg.autoRepeatDelay != null) "-ardelay ${toString cfg.autoRepeatDelay}"
    ++ optional (cfg.autoRepeatInterval != null) "-arinterval ${toString cfg.autoRepeatInterval}"
    ++ optional cfg.terminateOnReset "-terminate";

    # We ignore unknown drivers here because they may be resolved by other modules (e.g., the Nvidia
    # module). We assert that all specified drivers were eventually found in the assertions below.
    services.xserver.drivers = flip concatMap cfg.videoDrivers (
      name:
      lib.optional (videoDrivers ? ${name}) (
        {
          inherit name;
          display = true;
          driverName = name;
          modules = [ ];
        }
        // videoDrivers.${name}
      )
    );

    services.xserver.modules = concatLists (catAttrs "modules" cfg.drivers) ++ [
      pkgs.xorg-server.out
      pkgs.xf86-input-evdev.out
    ];

    services.xserver.videoDrivers = mkIf (cfg.videoDriver != null) [ cfg.videoDriver ];

    system.checks = singleton (
      pkgs.runCommand "xkb-validated"
        {
          inherit (cfg.xkb)
            dir
            model
            layout
            variant
            options
            ;

          nativeBuildInputs = with pkgs.buildPackages; [ xkbvalidate ];
          preferLocalBuild = true;
        }
        ''
          ${optionalString (
            config.environment.sessionVariables ? XKB_CONFIG_ROOT
          ) "export XKB_CONFIG_ROOT=${config.environment.sessionVariables.XKB_CONFIG_ROOT}"}
          XKB_CONFIG_ROOT="$dir" xkbvalidate "$model" "$layout" "$variant" "$options"
          touch "$out"
        ''
    );

  };

  # uses relatedPackages
  meta.buildDocsInSandbox = false;
}
