{
  config,
  lib,
  pkgs,
  ...
}:
let

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkPackageOption
    mkRemovedOptionModule
    types
    ;

  cfg = config.security.polkit;

  iniFmt = pkgs.formats.ini { };
in

{
  imports = [
    (mkRemovedOptionModule [ "security" "polkit" "debug" ] "Use security.polkit.extraArgs instead")
  ];

  options.security.polkit = {
    enable = mkEnableOption "polkit";
    package = mkPackageOption pkgs "polkit" { };

    adminIdentities = mkOption {
      default = [ "unix-group:wheel" ];

      description = ''
        Specifies which users are considered “administrators”, for those
        actions that require the user to authenticate as an
        administrator (i.e. have an `auth_admin`
        value).  By default, this is all users in the `wheel` group.
      '';

      example = [
        "unix-user:alice"
        "unix-group:admin"
      ];

      type = with types; listOf str;
    };

    enablePkexecWrapper = mkEnableOption "the setuid pkexec wrapper";

    extraArgs = mkOption {
      default = [
        "--no-debug"
        "--log-level=notice"
      ];

      description = ''
        List of arguments to pass to the polkitd executable.

        ::: {.note}
        To see debug logs you need to negate the default `--no-debug` setting.
        :::
      '';

      type = types.listOf types.str;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        Any polkit rules to be added to config (in JavaScript ;-). See:
        <https://www.freedesktop.org/software/polkit/docs/latest/polkit.8.html#polkit-rules>
      '';

      example = ''
        /* Log authorization checks. */
        polkit.addRule(function(action, subject) {
          // Make sure to negate --no-debug in services.polkit.extraArgs: { security.polkit.extraArgs = [ "--log-level=notice" ]; }
          polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid);
        });

        /* Allow any local user to do anything (dangerous!). */
        polkit.addRule(function(action, subject) {
          if (subject.local) return "yes";
        });
      '';

      type = types.lines;
    };

    settings = mkOption {
      description = ''
        Options for polkitd.
        See {manpage}`polkitd.conf(5)` for available options.
      '';

      type = types.submodule {
        options.Polkitd.ExpirationSeconds = lib.mkOption {
          default = 300; # current polkit upstream default
          description = "Expiration timeout of authenticated sesssions.";
          type = types.ints.positive;
        };

        freeformType = iniFmt.type;
      };
    };

  };

  config = mkIf cfg.enable {

    environment.etc."polkit-1/polkitd.conf".source = iniFmt.generate "polkitd.conf" cfg.settings;

    # PolKit rules for NixOS.
    environment.etc."polkit-1/rules.d/10-nixos.rules".text = ''
      polkit.addAdminRule(function(action, subject) {
        return [${lib.concatStringsSep ", " (map (i: "\"${i}\"") cfg.adminIdentities)}];
      });

      ${cfg.extraConfig}
    ''; # TODO: validation on compilation (at least against typos)

    # The polkit daemon reads action/rule files
    environment.pathsToLink = [ "/share/polkit-1" ];

    environment.systemPackages = [
      cfg.package.bin
      cfg.package.out
    ];

    security.pam.services.polkit-1 = { };

    security.wrappers.pkexec = {
      enable = cfg.enablePkexecWrapper;
      group = "root";
      owner = "root";
      setuid = true;
      source = lib.getExe' cfg.package "pkexec";
    };

    services.dbus.packages = [ cfg.package.out ];
    systemd.packages = [ cfg.package.out ];

    systemd.services.polkit = {
      reloadTriggers = [
        config.environment.etc."polkit-1/rules.d/10-nixos.rules".source
      ];

      restartTriggers = [ config.system.path ];

      serviceConfig.ExecStart = [
        # nuke default ExecStart
        ""
        # provide our own instead
        (toString (
          [
            "${lib.getLib cfg.package}/lib/polkit-1/polkitd"
          ]
          ++ cfg.extraArgs
        ))
      ];
    };

    systemd.services."polkit-agent-helper@".serviceConfig = lib.mkMerge [
      # The upstream unit inherits stderr to the polkit agent, which causes
      # agent processes to misinterpret diagnostic output from PAM modules
      # as protocol errors, resulting in tight re-execution loops.
      { StandardError = "journal"; }

      # The upstream unit uses PrivateDevices=yes and ProtectHome=yes,
      # which prevents PAM modules from accessing hardware (e.g. FIDO
      # tokens via /dev/hidraw*) or reading key files from home directories.
      (mkIf config.security.pam.u2f.enable {
        DeviceAllow = [
          "/dev/urandom r"
          "char-hidraw rw"
        ];

        # Override upstream PrivateDevices=yes to allow access to /dev/hidraw*
        PrivateDevices = false;
        # Override upstream ProtectHome=yes so pam_u2f can read
        # ~/.config/Yubico/u2f_keys (the default key file location)
        ProtectHome = "read-only";
      })
      (mkIf config.security.pam.zfs.enable {
        DeviceAllow = [
          "/dev/zfs rw"
        ];

        PrivateDevices = false;
      })
    ];

    systemd.sockets."polkit-agent-helper".wantedBy = [ "sockets.target" ];
    users.groups.polkituser = { };

    users.users.polkituser = {
      description = "PolKit daemon";
      group = "polkituser";
      uid = config.ids.uids.polkituser;
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ zimward ];
  };
}
