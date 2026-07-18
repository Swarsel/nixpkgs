# Configuration for the pwdutils suite of tools: passwd, useradd, etc.
{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.security.loginDefs;
in
{
  options = {

    security.loginDefs = {
      package = lib.mkPackageOption pkgs "shadow" { };

      chfnRestrict = lib.mkOption {
        default = null;

        description = ''
          Use chfn SUID to allow non-root users to change their account GECOS information.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Config options for the /etc/login.defs file, that defines
          the site-specific configuration for the shadow password suite.
          See {manpage}`login.defs(5)` man page for available options.
        '';

        type = lib.types.submodule {
          /*
            There are three different sources for user/group id ranges, each of which gets
            used by different programs:
            - The login.defs file, used by the useradd, groupadd and newusers commands
            - The update-users-groups.pl file, used by NixOS in the activation phase to
              decide on which ids to use for declaratively defined users without a static
              id
            - Systemd compile time options -Dsystem-uid-max= and -Dsystem-gid-max=, used
              by systemd for features like ConditionUser=@system and systemd-sysusers
          */
          options = {
            DEFAULT_HOME = lib.mkOption {
              default = "yes";
              description = "Indicate if login is allowed if we can't cd to the home directory.";

              type = lib.types.enum [
                "yes"
                "no"
              ];
            };

            ENCRYPT_METHOD = lib.mkOption {
              # The default crypt() method, keep in sync with the PAM default
              default = "YESCRYPT";
              description = "This defines the system default encryption algorithm for encrypting passwords.";

              type = lib.types.enum [
                "YESCRYPT"
                "SHA512"
                "SHA256"
                "MD5"
                "DES"
              ];
            };

            GID_MAX = lib.mkOption {
              default = 29999;
              description = "Range of group IDs used for the creation of regular groups by useradd, groupadd, or newusers.";
              type = lib.types.ints.u32;
            };

            GID_MIN = lib.mkOption {
              default = 1000;
              description = "Range of group IDs used for the creation of regular groups by useradd, groupadd, or newusers.";
              type = lib.types.ints.u32;
            };

            SYS_GID_MAX = lib.mkOption {
              default = 999;
              description = "Range of group IDs used for the creation of system groups by useradd, groupadd, or newusers";
              type = lib.types.ints.u32;
            };

            SYS_GID_MIN = lib.mkOption {
              default = 400;
              description = "Range of group IDs used for the creation of system groups by useradd, groupadd, or newusers";
              type = lib.types.ints.u32;
            };

            SYS_UID_MAX = lib.mkOption {
              default = 999;
              description = "Range of user IDs used for the creation of system users by useradd or newusers.";
              type = lib.types.ints.u32;
            };

            SYS_UID_MIN = lib.mkOption {
              default = 400;
              description = "Range of user IDs used for the creation of system users by useradd or newusers.";
              type = lib.types.ints.u32;
            };

            TTYGROUP = lib.mkOption {
              default = "tty";

              description = ''
                The terminal permissions: the login tty will be owned by the TTYGROUP group,
                and the permissions will be set to TTYPERM'';

              type = lib.types.str;
            };

            TTYPERM = lib.mkOption {
              default = "0620";

              description = ''
                The terminal permissions: the login tty will be owned by the TTYGROUP group,
                and the permissions will be set to TTYPERM'';

              type = lib.types.str;
            };

            UID_MAX = lib.mkOption {
              default = 29999;
              description = "Range of user IDs used for the creation of regular users by useradd or newusers.";
              type = lib.types.ints.u32;
            };

            UID_MIN = lib.mkOption {
              default = 1000;
              description = "Range of user IDs used for the creation of regular users by useradd or newusers.";
              type = lib.types.ints.u32;
            };

            # Ensure privacy for newly created home directories.
            UMASK = lib.mkOption {
              default = "077";
              description = "The file mode creation mask is initialized to this value.";
              type = lib.types.str;
            };
          };

          freeformType = (pkgs.formats.keyValue { }).type;
        };
      };
    };

    security.shadow.enable = lib.mkEnableOption "" // {
      default = true;

      description = ''
        Enable the shadow authentication suite, which provides critical programs such as su, login, passwd.

        Note: This is currently experimental. Only disable this if you're
        confident that you can recover your system if it breaks.
      '';
    };

    security.shadow.su.package = lib.mkPackageOption pkgs [ "shadow" "su" ] {
      extraDescription = ''
        This can be overridden by other modules (e.g. sudo-rs) to provide
        an alternative `su` implementation.
      '';
    };

    users.defaultUserShell = lib.mkOption {
      # /bin/sh is also the compiled in default of the shadow package.
      default = "/bin/sh";

      description = ''
        This option defines the default shell assigned to user
        accounts. This can be either a full system path or a shell package.

        This must not be a store path, since the path is
        used outside the store (in particular in /etc/passwd).
      '';

      example = lib.literalExpression "pkgs.zsh";
      type = lib.types.either lib.types.path lib.types.shellPackage;
    };
  };

  ###### implementation

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = config.security.shadow.enable || config.services.greetd.enable;
          message = "You must enable at least one VT login method, either security.shadow.enable or services.greetd.enable";
        }
      ];
    }
    (lib.mkIf config.security.shadow.enable {
      assertions = [
        {
          assertion = cfg.settings.SYS_UID_MIN <= cfg.settings.SYS_UID_MAX;
          message = "SYS_UID_MIN must be less than or equal to SYS_UID_MAX";
        }
        {
          assertion = cfg.settings.UID_MIN <= cfg.settings.UID_MAX;
          message = "UID_MIN must be less than or equal to UID_MAX";
        }
        {
          assertion = cfg.settings.SYS_GID_MIN <= cfg.settings.SYS_GID_MAX;
          message = "SYS_GID_MIN must be less than or equal to SYS_GID_MAX";
        }
        {
          assertion = cfg.settings.GID_MIN <= cfg.settings.GID_MAX;
          message = "GID_MIN must be less than or equal to GID_MAX";
        }
      ];

      environment.etc =
        # Create custom toKeyValue generator
        # see https://man7.org/linux/man-pages/man5/login.defs.5.html for config specification
        let
          toKeyValue = lib.generators.toKeyValue {
            mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
          };
        in
        {
          # /etc/default/useradd: configuration for useradd.
          "default/useradd".source = pkgs.writeText "useradd" ''
            GROUP=100
            HOME=${config.users.defaultUserHome}
            SHELL=${utils.toShellPath config.users.defaultUserShell}
          '';

          # /etc/login.defs: global configuration for pwdutils.
          # You cannot login without it!
          "login.defs".source = pkgs.writeText "login.defs" (toKeyValue cfg.settings);
        };

      environment.systemPackages =
        lib.optional config.users.mutableUsers cfg.package
        ++ lib.optional (lib.types.shellPackage.check config.users.defaultUserShell) config.users.defaultUserShell
        ++ lib.optional (cfg.chfnRestrict != null) pkgs.util-linux;

      security.loginDefs.settings.CHFN_RESTRICT = lib.mkIf (cfg.chfnRestrict != null) cfg.chfnRestrict;

      security.pam.services = {
        chfn.rootOK = true;
        chpasswd.rootOK = true;
        chsh.rootOK = true;
        groupadd.rootOK = true;
        groupdel.rootOK = true;
        groupmems.rootOK = true;
        groupmod.rootOK = true;

        login = {
          allowNullPassword = true;
          lastlog.enable = true;
          showMotd = true;
          startSession = true;
        };

        passwd = { };

        su = {
          forwardXAuth = true;
          logFailures = true;
          rootOK = true;
        };

        # Note: useradd, groupadd etc. aren't setuid root, so it
        # doesn't really matter what the PAM config says as long as it
        # lets root in.
        useradd.rootOK = true;
        userdel.rootOK = true;
        usermod.rootOK = true;
      };

      security.wrappers =
        let
          mkSetuidRoot = source: {
            inherit source;
            group = "root";
            owner = "root";
            setuid = true;
          };
          mkCapRoot = capabilities: source: {
            inherit capabilities source;
            group = "root";
            owner = "root";
          };
        in
        {
          newgidmap = mkCapRoot "cap_setgid+ep" "${cfg.package.out}/bin/newgidmap";
          newgrp = mkSetuidRoot "${cfg.package.out}/bin/newgrp";
          # File capabilities instead of setuid root, mirroring shadow's
          # own --with-fcaps install mode and what Arch/Fedora/Debian ship.
          # The kernel only requires CAP_SETUID/CAP_SETGID over the parent
          # userns to write a multi-line /proc/<pid>/[ug]id_map.
          newuidmap = mkCapRoot "cap_setuid+ep" "${cfg.package.out}/bin/newuidmap";
          sg = mkSetuidRoot "${cfg.package.out}/bin/sg";
          su = mkSetuidRoot "${config.security.shadow.su.package}/bin/su";
        }
        // lib.optionalAttrs config.users.mutableUsers {
          chsh = mkSetuidRoot "${cfg.package.out}/bin/chsh";
          passwd = mkSetuidRoot "${cfg.package.out}/bin/passwd";
        };
    })
  ];
}
