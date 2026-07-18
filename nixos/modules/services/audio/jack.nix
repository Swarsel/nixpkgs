{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jack;

  pcmPlugin = cfg.jackd.enable && cfg.alsa.enable;
  loopback = cfg.jackd.enable && cfg.loopback.enable;

  enable32BitAlsaPlugins =
    cfg.alsa.support32Bit && pkgs.stdenv.hostPlatform.isx86_64 && pkgs.pkgsi686Linux.alsa-lib != null;

  umaskNeeded = lib.versionOlder cfg.jackd.package.version "1.9.12";
  bridgeNeeded = lib.versionAtLeast cfg.jackd.package.version "1.9.12";
in
{
  options = {
    services.jack = {
      alsa = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Route audio to/from generic ALSA-using applications using ALSA JACK PCM plugin.
          '';

          type = lib.types.bool;
        };

        support32Bit = lib.mkOption {
          default = false;

          description = ''
            Whether to support sound for 32-bit ALSA applications on 64-bit system.
          '';

          type = lib.types.bool;
        };
      };

      jackd = {
        enable = lib.mkEnableOption ''
          JACK Audio Connection Kit. You need to add yourself to the "jackaudio" group
        '';

        package =
          lib.mkPackageOption pkgs "jack2" {
            example = "jack1";
          }
          // {
            # until jack1 promiscuous mode is fixed
            internal = true;
          };

        extraOptions = lib.mkOption {
          default = [
            "-dalsa"
          ];

          description = ''
            Specifies startup command line arguments to pass to JACK server.
          '';

          example = lib.literalExpression ''
            [ "-dalsa" "--device" "hw:1" ];
          '';

          type = lib.types.listOf lib.types.str;
        };

        session = lib.mkOption {
          description = ''
            Commands to run after JACK is started.
          '';

          type = lib.types.lines;
        };

      };

      loopback = {
        config = lib.mkOption {
          description = ''
            ALSA config for loopback device.
          '';

          type = lib.types.lines;
        };

        enable = lib.mkOption {
          default = false;

          description = ''
            Create ALSA loopback device, instead of using PCM plugin. Has broader
            application support (things like Steam will work), but may need fine-tuning
            for concrete hardware.
          '';

          type = lib.types.bool;
        };

        dmixConfig = lib.mkOption {
          default = "";

          description = ''
            For music production software that still doesn't support JACK natively you
            would like to put buffer/period adjustments here
            to decrease dmix device latency.
          '';

          example = ''
            period_size 2048
            periods 2
          '';

          type = lib.types.lines;
        };

        index = lib.mkOption {
          default = 10;

          description = ''
            Index of an ALSA loopback device.
          '';

          type = lib.types.int;
        };

        session = lib.mkOption {
          description = ''
            Additional commands to run to setup loopback device.
          '';

          type = lib.types.lines;
        };
      };

    };

  };

  config = lib.mkMerge [

    (lib.mkIf pcmPlugin {
      environment.etc."alsa/conf.d/98-jack.conf".text = ''
        pcm_type.jack {
          libs.native = ${pkgs.alsa-plugins}/lib/alsa-lib/libasound_module_pcm_jack.so ;
          ${lib.optionalString enable32BitAlsaPlugins "libs.32Bit = ${pkgs.pkgsi686Linux.alsa-plugins}/lib/alsa-lib/libasound_module_pcm_jack.so ;"}
        }
        pcm.!default {
          @func getenv
          vars [ PCM ]
          default "plug:jack"
        }
      '';
    })

    (lib.mkIf loopback {
      boot.kernelModules = [ "snd-aloop" ];
      boot.kernelParams = [ "snd-aloop.index=${toString cfg.loopback.index}" ];
      environment.etc."alsa/conf.d/99-jack-loopback.conf".text = cfg.loopback.config;
    })

    (lib.mkIf cfg.jackd.enable {
      assertions = [
        {
          assertion = !(cfg.alsa.enable && cfg.loopback.enable);
          message = "For JACK both alsa and loopback options shouldn't be used at the same time.";
        }
      ];

      environment = {
        etc."alsa/conf.d/50-jack.conf".source = "${pkgs.alsa-plugins}/etc/alsa/conf.d/50-jack.conf";
        systemPackages = [ cfg.jackd.package ];
        variables.JACK_PROMISCUOUS_SERVER = "jackaudio";
      };

      # https://jackaudio.org/faq/linux_rt_config.html
      security.pam.loginLimits = [
        {
          domain = "@jackaudio";
          item = "rtprio";
          type = "-";
          value = "99";
        }
        {
          domain = "@jackaudio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
      ];

      services.jack.jackd.session = ''
        ${lib.optionalString bridgeNeeded "${pkgs.a2jmidid}/bin/a2jmidid -e &"}
      '';

      # https://alsa.opensrc.org/Jack_and_Loopback_device_as_Alsa-to-Jack_bridge#id06
      services.jack.loopback.config = ''
        pcm.loophw00 {
          type hw
          card ${toString cfg.loopback.index}
          device 0
          subdevice 0
        }
        pcm.amix {
          type dmix
          ipc_key 219345
          slave {
            pcm loophw00
            ${cfg.loopback.dmixConfig}
          }
        }
        pcm.asoftvol {
          type softvol
          slave.pcm "amix"
          control { name Master }
        }
        pcm.cloop {
          type hw
          card ${toString cfg.loopback.index}
          device 1
          subdevice 0
          format S32_LE
        }
        pcm.loophw01 {
          type hw
          card ${toString cfg.loopback.index}
          device 0
          subdevice 1
        }
        pcm.ploop {
          type hw
          card ${toString cfg.loopback.index}
          device 1
          subdevice 1
          format S32_LE
        }
        pcm.aduplex {
          type asym
          playback.pcm "asoftvol"
          capture.pcm "loophw01"
        }
        pcm.!default {
          type plug
          slave.pcm aduplex
        }
      '';

      services.jack.loopback.session = ''
        alsa_in -j cloop -dcloop &
        alsa_out -j ploop -dploop &
        while [ "$(jack_lsp cloop)" == "" ] || [ "$(jack_lsp ploop)" == "" ]; do sleep 1; done
        jack_connect cloop:capture_1 system:playback_1
        jack_connect cloop:capture_2 system:playback_2
        jack_connect system:capture_1 ploop:playback_1
        jack_connect system:capture_2 ploop:playback_2
      '';

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="sound", ATTRS{id}!="Loopback", TAG+="systemd", ENV{SYSTEMD_WANTS}="jack.service"
      '';

      systemd.services.jack = {
        description = "JACK Audio Connection Kit";

        environment = {
          JACK_NO_AUDIO_RESERVATION = "1";
          JACK_PROMISCUOUS_SERVER = "jackaudio";
        };

        path = [ cfg.jackd.package ];
        restartIfChanged = false;

        serviceConfig = {
          ExecStart = "${cfg.jackd.package}/bin/jackd ${lib.escapeShellArgs cfg.jackd.extraOptions}";
          LimitMEMLOCK = "infinity";
          LimitRTPRIO = 99;

          SupplementaryGroups = lib.optional (
            config.services.pulseaudio.enable && !config.services.pulseaudio.systemWide
          ) "users";

          User = "jackaudio";
        }
        // lib.optionalAttrs umaskNeeded {
          UMask = "007";
        };
      };

      systemd.services.jack-session = {
        after = [ "jack.service" ];
        description = "JACK session";

        environment = {
          HOME = "/var/lib/jack";
          JACK_PROMISCUOUS_SERVER = "jackaudio";
        };

        partOf = [ "jack.service" ];
        path = [ cfg.jackd.package ];
        restartIfChanged = false;

        script = ''
          ${pkgs.jack-example-tools}/bin/jack_wait -w
          ${cfg.jackd.session}
          ${lib.optionalString cfg.loopback.enable cfg.loopback.session}
        '';

        serviceConfig = {
          LimitMEMLOCK = "infinity";
          LimitRTPRIO = 99;
          RemainAfterExit = true;
          StateDirectory = "jack";
          User = "jackaudio";
        };

        wantedBy = [ "jack.service" ];
      };

      users.groups.jackaudio = { };

      users.users.jackaudio = {
        description = "JACK Audio system service user";
        extraGroups = [ "audio" ];
        group = "jackaudio";
        isSystemUser = true;
      };
    })

  ];

  meta.maintainers = [ ];
}
