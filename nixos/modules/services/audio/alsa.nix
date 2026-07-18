{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.alsa;

  quote = x: ''"${lib.escape [ "\"" ] x}"'';

  alsactl = lib.getExe' pkgs.alsa-utils "alsactl";

  # Creates a volume control
  mkControl = name: opts: ''
    pcm.${name} {
      type softvol
      slave.pcm ${quote opts.device}
      control.name ${quote (if opts.name != null then opts.name else name)}
      control.card ${quote opts.card}
      max_dB ${toString opts.maxVolume}
    }
  '';

  # modprobe.conf for naming sound cards
  cardsConfig =
    let
      # Reverse the mapping from card name→driver to card driver→name
      drivers = lib.unique (lib.mapAttrsToList (n: v: v.driver) cfg.cardAliases);
      options = lib.forEach drivers (
        drv:
        let
          byDriver = lib.filterAttrs (n: v: v.driver == drv);
          ids = lib.mapAttrs (n: v: v.id) (byDriver cfg.cardAliases);
        in
        {
          driver = drv;
          ids = lib.attrValues ids;
          names = lib.attrNames ids;
        }
      );
      toList = x: lib.concatStringsSep "," (map toString x);
    in
    lib.forEach options (i: "options ${i.driver} index=${toList i.ids} id=${toList i.names}");

  pluginsPath = pkgs.symlinkJoin {
    name = "alsa-with-plugins";
    paths = cfg.plugins;
  };

  alsaVariables = {
    "ALSA_AUDIO_IN" = cfg.defaultDevice.capture;
    "ALSA_AUDIO_OUT" = cfg.defaultDevice.playback;
    "ALSA_PLUGIN_DIR" = lib.mkIf (cfg.plugins != [ ]) "${pluginsPath}/lib/alsa-lib";
  };

in

{
  imports = [
    (lib.mkRemovedOptionModule [ "sound" "enable" ] ''
      The option was heavily overloaded and can be removed from most configurations.
      To specifically configure the user space part of ALSA, see `hardware.alsa`.
    '')
    (lib.mkRemovedOptionModule [ "sound" "mediaKeys" ] ''
      The media keys can be configured with any hotkey daemon (that better
      integrates with your desktop setup). To continue using the actkbd daemon
      (which was used up to NixOS 24.05), add these lines to your configuration:

        services.actkbd.enable = true;
        services.actkbd.bindings = [
          # Mute
          { keys = [ 113 ]; events = [ "key" ];
            command = "''${pkgs.alsa-utils}/bin/amixer -q set Master toggle";
          }
          # Volume down
          { keys = [ 114 ]; events = [ "key" "rep" ];
            command = "''${pkgs.alsa-utils}/bin/amixer -q set Master 1- unmute";
          }
          # Volume up
          { keys = [ 115 ]; events = [ "key" "rep" ];
            command = "''${pkgs.alsa-utils}/bin/amixer -q set Master 1+ unmute";
          }
          # Mic Mute
          { keys = [ 190 ]; events = [ "key" ];
            command = "''${pkgs.alsa-utils}/bin/amixer -q set Capture toggle";
          }
        ];
    '')
    (lib.mkRenamedOptionModule
      [ "sound" "enableOSSEmulation" ]
      [ "hardware" "alsa" "enableOSSEmulation" ]
    )
    (lib.mkRenamedOptionModule [ "sound" "extraConfig" ] [ "hardware" "alsa" "config" ])
  ];

  options.hardware.alsa = {

    config = lib.mkOption {
      default = "";

      description = ''
        The content of the system-wide ALSA configuration (/etc/asound.conf).

        Documentation of the configuration language and examples can be found
        in the unofficial ALSA wiki: <https://alsa.opensrc.org/Asoundrc>
      '';

      example = lib.literalExpression ''
        # Send audio to a remote host via SSH
        pcm.remote {
          @args [ HOSTNAME ]
          @args.HOSTNAME { type string }
          type file
          format raw
          slave.pcm pcm.null
          file {
            @func concat
            strings [
              "| ''${lib.getExec pkgs.openssh} -C "
              $HOSTNAME
              " aplay -f %f -c %c -r %r -"
            ]
          }
        }
      '';

      type = lib.types.lines;
    };

    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to set up the user space part of the Advanced Linux Sound Architecture (ALSA)

        ::: {.warning}
        Enable this option only if you want to use ALSA as your main sound system,
        not if you're using a sound server (e.g. PulseAudio or Pipewire).
        :::
      '';

      type = lib.types.bool;
    };

    cardAliases = lib.mkOption {
      default = { };

      description = ''
        Assign custom names and reorder the sound cards.

        ::: {.note}
        You can find the card ids by looking at `/proc/asound/cards`.
        :::
      '';

      example = lib.literalExpression ''
        {
          soundchip = { driver = "snd_intel_hda"; id = 0; };
          videocard = { driver = "snd_intel_hda"; id = 1; };
          usb       = { driver = "snd_usb_audio"; id = 2; };
        }
      '';

      type = lib.types.attrsOf (
        lib.types.submodule {
          options.driver = lib.mkOption {
            description = ''
              Name of the kernel module that provides the card.
            '';

            type = lib.types.str;
          };

          options.id = lib.mkOption {
            default = "default";

            description = ''
              The ID of the sound card
            '';

            type = lib.types.int;
          };
        }
      );
    };

    controls = lib.mkOption {
      default = { };

      description = ''
        Virtual volume controls (softvols) to add to a sound card.
        These can be used to control the volume of specific applications
        or a digital output device (HDMI video card).
      '';

      example = lib.literalExpression ''
        {
          firefox = { device = "front"; maxVolume = -25.0; };
          mpv     = { device = "front"; maxVolume = -25.0; };
          # and run programs with `env ALSA_AUDIO_OUT=<name>`
        }
      '';

      type = lib.types.attrsOf (
        lib.types.submodule {
          options.card = lib.mkOption {
            default = "default";

            description = ''
              Name of the PCM card to control (slave).
            '';

            type = lib.types.str;
          };

          options.device = lib.mkOption {
            default = "default";

            description = ''
              Name of the PCM device to control (slave).
            '';

            type = lib.types.str;
          };

          options.maxVolume = lib.mkOption {
            default = 0.0;

            description = ''
              The maximum volume in dB.
            '';

            type = lib.types.float;
          };

          options.name = lib.mkOption {
            default = null;

            description = ''
              Name of the control, as it appears in `alsamixer`.
              If null it will be the same as the softvol device name.
            '';

            type = lib.types.nullOr lib.types.str;
          };
        }
      );
    };

    defaultDevice.capture = lib.mkOption {
      default = "";

      description = ''
        The default capture device (i.e. microphone).
        Leave empty to let ALSA pick the default automatically.

        ::: {.note}
        The device can be changed at runtime by setting the ALSA_AUDIO_IN
        environment variables (but only before starting a program).
        :::
      '';

      example = "dsnoop:CARD=0,DEV=2";
      type = lib.types.str;
    };

    defaultDevice.playback = lib.mkOption {
      default = "";

      description = ''
        The default playback device.
        Leave empty to let ALSA pick the default automatically.

        ::: {.note}
        The device can be changed at runtime by setting the ALSA_AUDIO_OUT
        environment variables (but only before starting a program).
        :::
      '';

      example = "dmix:CARD=1,DEV=0";
      type = lib.types.str;
    };

    deviceAliases = lib.mkOption {
      default = { };

      description = ''
        Assign custom names to sound cards.
      '';

      example = lib.literalExpression ''
        {
          hdmi1 = "hw:CARD=videocard,DEV=5";
          hdmi2 = "hw:CARD=videocard,DEV=6";
        }
      '';

      type = lib.types.attrsOf lib.types.str;
    };

    enableBluetooth = lib.mkEnableOption "Bluetooth audio support via BlueALSA";
    enableOSSEmulation = lib.mkEnableOption "the OSS emulation";

    enableRecorder = lib.mkOption {
      default = false;

      description = ''
        Whether to set up a loopback device that continuously records and
        allows to play back audio from the computer.

        The loopback device is named `pcm.recorder`, audio can be saved
        by capturing from this device as with any microphone.

        ::: {.note}
        By default the output is duplicated to the recorder assuming stereo
        audio, for a more complex layout you have to override the pcm.splitter
        device using `hardware.alsa.config`.
        See the generated /etc/asound.conf for its definition.
        :::
      '';

      type = lib.types.bool;
    };

    plugins = lib.mkOption {
      default = [ ];

      description = ''
        List of ALSA plugins to be added to the search path.
      '';

      example = lib.literalExpression "[ pkgs.bluez-alsa ]";
      type = lib.types.listOf lib.types.package;
    };

  };

  options.hardware.alsa.enablePersistence = lib.mkOption {
    default = config.hardware.alsa.enable;
    defaultText = lib.literalExpression "config.hardware.alsa.enable";

    description = ''
      Whether to enable ALSA sound card state saving on shutdown.
      This is generally not necessary if you're using an external sound server.
    '';

    type = lib.types.bool;
  };

  config = lib.mkMerge [

    (lib.mkIf cfg.enable {
      # Assign names to the sound cards
      boot.extraModprobeConfig = lib.concatStringsSep "\n" cardsConfig;

      boot.kernelModules =
        [ ]
        ++ lib.optionals cfg.enableOSSEmulation [
          "snd_pcm_oss"
          "snd_mixer_oss"
        ]
        ++ lib.optionals cfg.enableRecorder [ "snd_aloop" ];

      environment.etc."asound.conf".text = cfg.config;
      # Set default PCM devices
      environment.sessionVariables = alsaVariables;
      # Provide alsamixer, aplay, arecord, etc.
      environment.systemPackages = [ pkgs.alsa-utils ];

      hardware.alsa.cardAliases = lib.mkIf cfg.enableRecorder {
        loopback.driver = "snd_aloop";
        loopback.id = 2;
      };

      hardware.alsa.config =
        let
          conf = [
            ''
              pcm.!default fromenv

              # Read the capture and playback device from
              # the ALSA_AUDIO_IN, ALSA_AUDIO_OUT variables
              pcm.fromenv {
                type asym
                playback.pcm {
                  type plug
                  slave.pcm {
                    @func getenv
                    vars [ ALSA_AUDIO_OUT ]
                    default pcm.sysdefault
                  }
                }
                capture.pcm {
                  type plug
                  slave.pcm {
                    @func getenv
                    vars [ ALSA_AUDIO_IN ]
                    default pcm.sysdefault
                  }
                }
              }
            ''
            (lib.optional cfg.enableRecorder ''
              pcm.!default "splitter:fromenv,recorder"

              # Send audio to two stereo devices
              pcm.splitter {
                @args [ A B ]
                @args.A.type string
                @args.B.type string
                type asym
                playback.pcm {
                  type plug
                  route_policy "duplicate"
                  slave.pcm {
                    type multi
                    slaves.a.pcm $A
                    slaves.b.pcm $B
                    slaves.a.channels 2
                    slaves.b.channels 2
                    bindings [
                     { slave a channel 0 }
                     { slave a channel 1 }
                     { slave b channel 0 }
                     { slave b channel 1 }
                    ]
                  }
                }
                capture.pcm $A
              }

              # Device which records and plays back audio
              pcm.recorder {
                type asym
                capture.pcm {
                  type dsnoop
                  ipc_key 9165218
                  ipc_perm 0666
                  slave.pcm "hw:loopback,1,0"
                  slave.period_size 1024
                  slave.buffer_size 8192
                }
                playback.pcm {
                  type dmix
                  ipc_key 6181923
                  ipc_perm 0666
                  slave.pcm "hw:loopback,0,0"
                  slave.period_size 1024
                  slave.buffer_size 8192
                }
              }
            '')
            (lib.mapAttrsToList mkControl cfg.controls)
            (lib.mapAttrsToList (n: v: "pcm.${n} ${quote v}") cfg.deviceAliases)
          ];
        in
        lib.mkBefore (lib.concatStringsSep "\n" (lib.flatten conf));

      # Disable sound servers enabled by default and,
      # if the user enabled one manually, cause a conflict.
      services.pipewire.enable = false;
      services.pulseaudio.enable = false;
      systemd.globalEnvironment = alsaVariables;
    })

    (lib.mkIf (cfg.enable && cfg.enableBluetooth) {

      # Link ALSA configuration
      environment.etc."alsa/conf.d/20-bluealsa.conf".source =
        "${pkgs.bluez-alsa}/etc/alsa/conf.d/20-bluealsa.conf";

      # Install CLI tools and systemd units
      environment.systemPackages = [ pkgs.bluez-alsa ];
      # Install plugin
      hardware.alsa.plugins = [ pkgs.bluez-alsa ];
      systemd.packages = [ pkgs.bluez-alsa ];
      # See Nixpkgs issue #81138
      systemd.services."bluealsa".wantedBy = [ "bluetooth.target" ];

      users.users.bluealsa = {
        description = "BlueALSA daemons user";
        group = "audio";
        isSystemUser = true;
      };
      # Note: bluealsa-aplay is available but we don't start it
      # by default, it's only needed to make the machine act as
      # bluetooth speaker
    })

    (lib.mkIf config.hardware.alsa.enablePersistence {

      # Install udev rules for restoring card settings on boot
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC*", KERNELS!="card*", GOTO="alsa_restore_go"
        GOTO="alsa_restore_end"

        LABEL="alsa_restore_go"
        TEST!="/etc/alsa/state-daemon.conf", RUN+="${alsactl} restore -gU $attr{device/number}"
        TEST=="/etc/alsa/state-daemon.conf", RUN+="${alsactl} nrestore -gU $attr{device/number}"
        LABEL="alsa_restore_end"
      '';

      # Service to store/restore the sound card settings
      systemd.services.alsa-store = {
        description = "Store Sound Card State";
        restartIfChanged = false;

        serviceConfig = {
          ExecStart = "${alsactl} restore -gU";
          ExecStop = "${alsactl} store -gU";
          RemainAfterExit = true;
          StateDirectory = "alsa";

          # Note: the service should never be restated, otherwise any
          # setting changed between the last `store` and now will be lost.
          # To prevent NixOS from starting it in case it has failed we
          # expand the exit codes considered successful
          SuccessExitStatus = [
            0
            99
          ];

          Type = "oneshot";
        };

        unitConfig = {
          ConditionVirtualization = "!systemd-nspawn";
          RequiresMountsFor = "/var/lib/alsa";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })

  ];

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
