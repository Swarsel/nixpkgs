{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tlp;
  enableRDW = config.networking.networkmanager.enable;
  # TODO: Use this for having proper parameters in the future
  mkTlpConfig =
    tlpConfig:
    lib.generators.toKeyValue {
      mkKeyValue = lib.generators.mkKeyValueDefault {
        mkValueString = val: if lib.isList val then "\"" + (toString val) + "\"" else toString val;
      } "=";
    } tlpConfig;
in
{
  ###### interface
  options = {
    services.tlp = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the TLP power management daemon.";
        type = lib.types.bool;
      };

      package = lib.mkOption {
        default = pkgs.tlp.override { inherit enableRDW; };
        defaultText = "pkgs.tlp.override { enableRDW = config.networking.networkmanager.enable; }";
        description = "The tlp package to use.";
        type = lib.types.package;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Verbatim additional configuration variables for TLP.
          DEPRECATED: use services.tlp.settings instead.
        '';

        type = lib.types.lines;
      };

      pd = {
        enable = lib.mkEnableOption "the power-rofiles-daemon like DBus interface for TLP";
        package = lib.mkPackageOption pkgs "tlp-pd" { };
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Options passed to TLP. See <https://linrunner.de/tlp> for all supported options..
        '';

        example = {
          SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
          USB_BLACKLIST_PHONE = 1;
        };

        type =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            float
            str
            (listOf str)
          ]);
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.powerManagement.scsiLinkPolicy == null;

        message = ''
          `services.tlp.enable` and `config.powerManagement.scsiLinkPolicy` cannot be set both.
          Set `services.tlp.settings.SATA_LINKPWR_ON_AC` and `services.tlp.settings.SATA_LINKPWR_ON_BAT` instead.
        '';
      }
      {
        assertion = cfg.pd.enable -> !config.services.power-profiles-daemon.enable;

        message = ''
          `services.tlp.pd` and `services.power-profiles-daemon` cannot be enabled together,
          because they are using the same dbus interface and have the same functionality.
          Generally, `services.tlp.pd` should be preferred as upstream does not recommend
          using tlp together with power-profiles-daemon.
          Set `services.power-profiles-daemon.enable` to `false` to resolve this error.
        '';
      }
      {
        assertion = cfg.pd.enable -> !(config.services.tuned.enable && config.services.tuned.ppdSupport);

        message = ''
          `services.tlp.pd` and `services.tuned.ppdSupport` cannot be enabled together,
          because they are using the same dbus interface and have the same functionality.
        '';
      }
    ];

    environment.etc = {
      "tlp.conf".text = (mkTlpConfig cfg.settings) + cfg.extraConfig;
    }
    // lib.optionalAttrs enableRDW {
      "NetworkManager/dispatcher.d/99tlp-rdw-nm".source =
        "${cfg.package}/lib/NetworkManager/dispatcher.d/99tlp-rdw-nm";
    };

    environment.systemPackages = [
      cfg.package
    ]
    ++ lib.optionals cfg.pd.enable [ cfg.pd.package ];

    hardware.cpu.x86.msr.enable = true;

    services.tlp.settings =
      let
        cfg = config.powerManagement;
        maybeDefault = val: lib.mkIf (val != null) (lib.mkDefault val);
      in
      {
        CPU_SCALING_GOVERNOR_ON_AC = maybeDefault cfg.cpuFreqGovernor;
        CPU_SCALING_GOVERNOR_ON_BAT = maybeDefault cfg.cpuFreqGovernor;
        CPU_SCALING_MAX_FREQ_ON_AC = maybeDefault cfg.cpufreq.max;
        CPU_SCALING_MAX_FREQ_ON_BAT = maybeDefault cfg.cpufreq.max;
        CPU_SCALING_MIN_FREQ_ON_AC = maybeDefault cfg.cpufreq.min;
        CPU_SCALING_MIN_FREQ_ON_BAT = maybeDefault cfg.cpufreq.min;
      };

    services.udev.packages = [ cfg.package ];

    systemd = {
      packages = [
        cfg.package
      ]
      ++ lib.optionals cfg.pd.enable [ cfg.pd.package ];

      # use native tlp instead because it can also differentiate between AC/BAT
      services.cpufreq.enable = false;
      services.systemd-rfkill.enable = false;

      services.tlp = {
        # XXX: The service should reload whenever the configuration changes,
        # otherwise newly set power options remain inactive until reboot (or
        # manual unit restart.)
        restartTriggers = [ config.environment.etc."tlp.conf".source ];
        # XXX: When using systemd.packages (which we do above) the [Install]
        # section of systemd units does not work (citation needed) so we manually
        # enforce it here.
        wantedBy = [ "multi-user.target" ];
      };

      services.tlp-pd = lib.mkIf cfg.pd.enable {
        # have to define again because [Install] in included file not honored
        # https://github.com/NixOS/nixpkgs/issues/81138
        wantedBy = [ "graphical.target" ];
      };

      services.tlp-sleep = {
        # XXX: When using systemd.packages (which we do above) the [Install]
        # section of systemd units does not work (citation needed) so we manually
        # enforce it here.
        before = [ "sleep.target" ];
        # XXX: `tlp suspend` requires /var/lib/tlp to exist in order to save
        # some stuff in there. There is no way, that I know of, to do this in
        # the package itself, so we do it here instead making sure the unit
        # won't fail due to the save dir not existing.
        serviceConfig.StateDirectory = "tlp";
        wantedBy = [ "sleep.target" ];
      };

      # XXX: These must always be disabled/masked according to [1].
      #
      # [1]: https://github.com/linrunner/TLP/blob/a9ada09e0821f275ce5f93dc80a4d81a7ff62ae4/tlp-stat.in#L319
      sockets.systemd-rfkill.enable = false;
    };

    warnings = lib.optional (cfg.extraConfig != "") ''
      Using config.services.tlp.extraConfig is deprecated and will become unsupported in a future release. Use config.services.tlp.settings instead.
    '';
  };
}
