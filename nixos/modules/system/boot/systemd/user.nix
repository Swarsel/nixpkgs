{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.systemd.user;

  systemd = config.systemd.package;

  inherit (utils.systemdUtils.lib)
    generateUnits
    targetToUnit
    serviceToUnit
    sliceToUnit
    socketToUnit
    timerToUnit
    pathToUnit
    ;

  upstreamUserUnits = [
    "app.slice"
    "background.slice"
    "basic.target"
    "bluetooth.target"
    "capsule@.target"
    "default.target"
    "exit.target"
    "graphical-session-pre.target"
    "graphical-session.target"
    "paths.target"
    "printer.target"
    "session.slice"
    "shutdown.target"
    "smartcard.target"
    "sockets.target"
    "sound.target"
    "systemd-exit.service"
    "timers.target"
    "xdg-desktop-autostart.target"
  ]
  ++ config.systemd.additionalUpstreamUserUnits;

  writeTmpfiles =
    {
      rules,
      user ? null,
    }:
    let
      suffix = lib.optionalString (user != null) "-${user}";
    in
    pkgs.writeTextFile {
      destination = "/etc/xdg/user-tmpfiles.d/00-nixos${suffix}.conf";
      name = "nixos-user-tmpfiles.d${suffix}";

      text = ''
        # This file is created automatically and should not be modified.
        # Please change the options ‘systemd.user.tmpfiles’ instead.
        ${lib.concatStringsSep "\n" rules}
      '';
    };
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "systemd"
      "user"
      "extraConfig"
    ] "Use systemd.user.settings.Manager instead.")
  ];

  options = {
    systemd.additionalUpstreamUserUnits = lib.mkOption {
      default = [ ];

      description = ''
        Additional units shipped with systemd that should be enabled for per-user systemd instances.
      '';

      example = [ ];
      internal = true;
      type = lib.types.listOf lib.types.str;
    };

    systemd.user.generators = lib.mkOption {
      default = { };

      description = ''
        Definition of systemd generators; see {manpage}`systemd.generator(5)`.

        For each `NAME = VALUE` pair of the attrSet, a link is generated from
        `/etc/systemd/user-generators/NAME` to `VALUE`.
      '';

      example = {
        systemd-gpt-auto-generator = "/dev/null";
      };

      type = lib.types.attrsOf lib.types.path;
    };

    systemd.user.paths = lib.mkOption {
      default = { };
      description = "Definition of systemd per-user path units.";
      type = utils.systemdUtils.types.paths;
    };

    systemd.user.services = lib.mkOption {
      default = { };
      description = "Definition of systemd per-user service units.";
      type = utils.systemdUtils.types.services;
    };

    systemd.user.settings.Manager = lib.mkOption {
      default = { };

      description = ''
        Settings for systemd user instances. See {manpage}`systemd-user.conf(5)`
        for available options.
      '';

      example = {
        DefaultTimeoutStartSec = 60;
      };

      type = lib.types.submodule {
        freeformType = lib.types.attrsOf utils.systemdUtils.unitOptions.unitOption;
      };
    };

    systemd.user.slices = lib.mkOption {
      default = { };
      description = "Definition of systemd per-user slice units.";
      type = utils.systemdUtils.types.slices;
    };

    systemd.user.sockets = lib.mkOption {
      default = { };
      description = "Definition of systemd per-user socket units.";
      type = utils.systemdUtils.types.sockets;
    };

    systemd.user.targets = lib.mkOption {
      default = { };
      description = "Definition of systemd per-user target units.";
      type = utils.systemdUtils.types.targets;
    };

    systemd.user.timers = lib.mkOption {
      default = { };
      description = "Definition of systemd per-user timer units.";
      type = utils.systemdUtils.types.timers;
    };

    systemd.user.tmpfiles = {
      enable =
        (lib.mkEnableOption "systemd user units systemd-tmpfiles-setup.service and systemd-tmpfiles-clean.timer")
        // {
          default = true;
          example = false;
        };

      rules = lib.mkOption {
        default = [ ];

        description = ''
          Global user rules for creation, deletion and cleaning of volatile and
          temporary files automatically. See
          {manpage}`tmpfiles.d(5)`
          for the exact format.
        '';

        example = [ "D %C - - - 7d" ];
        type = lib.types.listOf lib.types.str;
      };

      users = lib.mkOption {
        default = { };

        description = ''
          Per-user rules for creation, deletion and cleaning of volatile and
          temporary files automatically.
        '';

        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              rules = lib.mkOption {
                default = [ ];

                description = ''
                  Per-user rules for creation, deletion and cleaning of volatile and
                  temporary files automatically. See
                  {manpage}`tmpfiles.d(5)`
                  for the exact format.
                '';

                example = [ "D %C - - - 7d" ];
                type = lib.types.listOf lib.types.str;
              };
            };
          }
        );
      };
    };

    systemd.user.units = lib.mkOption {
      default = { };
      description = "Definition of systemd per-user units.";
      type = utils.systemdUtils.types.units;
    };
  };

  config = {
    environment.etc = {
      "systemd/user".source = generateUnits {
        inherit (cfg) units;
        type = "user";
        upstreamUnits = upstreamUserUnits;
        upstreamWants = [ ];
      };

      "systemd/user.conf".text = utils.systemdUtils.lib.settingsToSections cfg.settings;
    };

    # /run/current-system/sw/etc/xdg is in systemd's $XDG_CONFIG_DIRS so we can
    # write the tmpfiles.d rules for everyone there
    environment.systemPackages = lib.optional (cfg.tmpfiles.rules != [ ]) (writeTmpfiles {
      inherit (cfg.tmpfiles) rules;
    });

    # Provide the systemd-user PAM service, required to run systemd
    # user instances.
    security.pam.services.systemd-user = {
      # Disable pam_mount in systemd-user to prevent it from being called
      # multiple times during login, because it will prevent pam_mount from
      # unmounting the previously mounted volumes.
      pamMount = false;
      # Ensure that pam_systemd gets included. This is special-cased
      # in systemd to provide XDG_RUNTIME_DIR.
      startSession = true;
    };

    system.userActivationScripts.tmpfiles = ''
      ${config.systemd.package}/bin/systemd-tmpfiles --user --create --remove
    '';

    systemd.additionalUpstreamSystemUnits = [
      "user.slice"
    ];

    systemd.services.systemd-user-sessions.restartIfChanged = false; # Restart kills all active sessions.
    # Some overrides to upstream units.
    systemd.services."user@".restartIfChanged = false;

    # enable systemd user tmpfiles
    systemd.user.services.systemd-tmpfiles-setup.wantedBy =
      lib.optional cfg.tmpfiles.enable "basic.target";

    systemd.user.timers = {
      # enable systemd user tmpfiles
      systemd-tmpfiles-clean.wantedBy = lib.optional cfg.tmpfiles.enable "timers.target";
    }
    # Generate timer units for all services that have a ‘startAt’ value.
    // (lib.mapAttrs (name: service: {
      timerConfig.OnCalendar = service.startAt;
      wantedBy = [ "timers.target" ];
    }) (lib.filterAttrs (name: service: service.startAt != [ ]) cfg.services));

    systemd.user.units =
      lib.mapAttrs' (n: v: lib.nameValuePair "${n}.path" (pathToUnit v)) cfg.paths
      // lib.mapAttrs' (n: v: lib.nameValuePair "${n}.service" (serviceToUnit v)) cfg.services
      // lib.mapAttrs' (n: v: lib.nameValuePair "${n}.slice" (sliceToUnit v)) cfg.slices
      // lib.mapAttrs' (n: v: lib.nameValuePair "${n}.socket" (socketToUnit v)) cfg.sockets
      // lib.mapAttrs' (n: v: lib.nameValuePair "${n}.target" (targetToUnit v)) cfg.targets
      // lib.mapAttrs' (n: v: lib.nameValuePair "${n}.timer" (timerToUnit v)) cfg.timers;

    # /etc/profiles/per-user/$USER/etc/xdg is in systemd's $XDG_CONFIG_DIRS so
    # we can write a single user's tmpfiles.d rules there
    users.users = lib.mapAttrs (user: cfg': {
      packages = lib.optional (cfg'.rules != [ ]) (writeTmpfiles {
        inherit (cfg') rules;
        inherit user;
      });
    }) cfg.tmpfiles.users;
  };
}
