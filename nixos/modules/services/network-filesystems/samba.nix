{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.samba;

  settingsFormat = pkgs.formats.ini {
    listToValue = lib.concatMapStringsSep " " (lib.generators.mkValueStringDefault { });
  };
  # Ensure the global section is always first
  globalConfigFile = settingsFormat.generate "smb-global.conf" { global = cfg.settings.global; };
  sharesConfigFile = settingsFormat.generate "smb-shares.conf" (
    lib.removeAttrs cfg.settings [ "global" ]
  );

  configFile = pkgs.concatText "smb.conf" [
    globalConfigFile
    sharesConfigFile
  ];

in

{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "samba" "defaultShare" ] "")
    (lib.mkRemovedOptionModule [ "services" "samba" "syncPasswordsByPam" ]
      "This option has been removed by upstream, see https://bugzilla.samba.org/show_bug.cgi?id=10669#c10"
    )

    (lib.mkRemovedOptionModule [ "services" "samba" "configText" ] ''
      Use services.samba.settings instead.

      This is part of the general move to use structured settings instead of raw
      text for config as introduced by RFC0042:
      https://github.com/NixOS/rfcs/blob/master/rfcs/0042-config-option.md
    '')
    (lib.mkRemovedOptionModule [
      "services"
      "samba"
      "extraConfig"
    ] "Use services.samba.settings instead.")
    (lib.mkRenamedOptionModule
      [ "services" "samba" "invalidUsers" ]
      [ "services" "samba" "settings" "global" "invalid users" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "samba" "securityType" ]
      [ "services" "samba" "settings" "global" "security" ]
    )
    (lib.mkRenamedOptionModule [ "services" "samba" "shares" ] [ "services" "samba" "settings" ])

    (lib.mkRenamedOptionModule
      [ "services" "samba" "enableWinbindd" ]
      [ "services" "samba" "winbindd" "enable" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "samba" "enableNmbd" ]
      [ "services" "samba" "nmbd" "enable" ]
    )
  ];

  ###### interface
  options = {
    services.samba = {
      enable = lib.mkEnableOption "Samba, the SMB/CIFS protocol";

      package = lib.mkPackageOption pkgs "samba" {
        example = "samba4Full";
      };

      nmbd = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Whether to enable Samba's nmbd, which replies to NetBIOS over IP name
            service requests. It also participates in the browsing protocols
            which make up the Windows "Network Neighborhood" view.
          '';

          type = lib.types.bool;
        };

        extraArgs = lib.mkOption {
          default = [ ];
          description = "Extra arguments to pass to the nmbd service.";
          type = lib.types.listOf lib.types.str;
        };
      };

      nsswins = lib.mkEnableOption ''
        WINS NSS (Name Service Switch) plug-in.

        Enabling it allows applications to resolve WINS/NetBIOS names (a.k.a.
        Windows machine names) by transparently querying the winbindd daemon
      '';

      openFirewall = lib.mkEnableOption "opening the default ports in the firewall for Samba";

      settings = lib.mkOption {
        default = {
          "global" = {
            "invalid users" = [ "root" ];
            "passwd program" = "/run/wrappers/bin/passwd %u";
            "security" = "user";
          };
        };

        description = ''
          Configuration file for the Samba suite in ini format.
          This file is located in /etc/samba/smb.conf

          Refer to <https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html>
          for all available options.
        '';

        example = {
          "global" = {
            "invalid users" = [ "root" ];
            "passwd program" = "/run/wrappers/bin/passwd %u";
            "security" = "user";
          };

          "public" = {
            "browseable" = "yes";
            "comment" = "Public samba share.";
            "guest ok" = "yes";
            "path" = "/srv/public";
            "read only" = "yes";
          };
        };

        type = lib.types.submodule {
          options = {
            global."invalid users" = lib.mkOption {
              default = [ "root" ];
              description = "List of users who are denied to login via Samba.";
              type = lib.types.listOf lib.types.str;
            };

            global."passwd program" = lib.mkOption {
              default = "/run/wrappers/bin/passwd %u";
              description = "Path to a program that can be used to set UNIX user passwords.";
              type = lib.types.str;
            };

            global.security = lib.mkOption {
              default = "user";
              description = "Samba security type.";

              type = lib.types.enum [
                "auto"
                "user"
                "domain"
                "ads"
              ];
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      smbd = {
        enable = lib.mkOption {
          default = true;
          description = "Whether to enable Samba's smbd daemon.";
          type = lib.types.bool;
        };

        extraArgs = lib.mkOption {
          default = [ ];
          description = "Extra arguments to pass to the smbd service.";
          type = lib.types.listOf lib.types.str;
        };
      };

      usershares = {
        enable = lib.mkEnableOption "user-configurable Samba shares";

        group = lib.mkOption {
          default = "samba";

          description = ''
            Name of the group members of which will be allowed to create usershares.

            The group will be created automatically.
          '';

          type = lib.types.str;
        };
      };

      winbindd = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Whether to enable Samba's winbindd, which provides a number of services
            to the Name Service Switch capability found in most modern C libraries,
            to arbitrary applications via PAM and ntlm_auth and to Samba itself.
          '';

          type = lib.types.bool;
        };

        extraArgs = lib.mkOption {
          default = [ ];
          description = "Extra arguments to pass to the winbindd service.";
          type = lib.types.listOf lib.types.str;
        };
      };
    };
  };

  ###### implementation
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.nsswins -> cfg.winbindd.enable;
          message = "If services.samba.nsswins is enabled, then services.samba.winbindd.enable must also be enabled";
        }
      ];
    }

    (lib.mkIf cfg.enable {
      environment.etc."samba/smb.conf".source = configFile;
      environment.systemPackages = [ cfg.package ];

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
        139
        445
      ];

      networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [
        137
        138
      ];

      security.pam.services.samba = { };

      # Like other mount* related commands that need the setuid bit, this is
      # required too.
      security.wrappers."mount.cifs" = {
        group = "root";
        owner = "root";
        program = "mount.cifs";
        setuid = true;
        source = "${lib.getBin pkgs.cifs-utils}/bin/mount.cifs";
      };

      system.nssDatabases.hosts = lib.optional cfg.nsswins "wins";
      system.nssModules = lib.optional cfg.nsswins cfg.package;

      systemd = {
        slices.system-samba = {
          description = "Samba (SMB Networking Protocol) Slice";
        };

        targets.samba = {
          after = [ "network.target" ];
          description = "Samba Server";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
        };

        tmpfiles.rules = [
          "d /var/lock/samba - - - - -"
          "d /var/log/samba - - - - -"
          "d /var/cache/samba - - - - -"
          "d /var/lib/samba/private - - - - -"
        ];
      };
    })

    (lib.mkIf (cfg.enable && cfg.nmbd.enable) {
      systemd.services.samba-nmbd = {
        after = [
          "network.target"
          "network-online.target"
        ];

        description = "Samba NMB Daemon";

        documentation = [
          "man:nmbd(8)"
          "man:samba(7)"
          "man:smb.conf(5)"
        ];

        environment.LD_LIBRARY_PATH = config.system.nssModules.path;
        partOf = [ "samba.target" ];
        restartTriggers = [ configFile ];

        serviceConfig = {
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          ExecStart = "${cfg.package}/sbin/nmbd --foreground --no-process-group ${lib.escapeShellArgs cfg.nmbd.extraArgs}";
          LimitCORE = "infinity";
          PIDFile = "/run/samba/nmbd.pid";
          Slice = "system-samba.slice";
          Type = "notify";
        };

        unitConfig.RequiresMountsFor = "/var/lib/samba";
        wantedBy = [ "samba.target" ];
        wants = [ "network-online.target" ];
      };
    })

    (lib.mkIf (cfg.enable && cfg.smbd.enable) {
      systemd.services.samba-smbd = {
        after = [
          "network.target"
          "network-online.target"
        ]
        ++ lib.optionals (cfg.nmbd.enable) [
          "samba-nmbd.service"
        ]
        ++ lib.optionals (cfg.winbindd.enable) [
          "samba-winbindd.service"
        ];

        description = "Samba SMB Daemon";

        documentation = [
          "man:smbd(8)"
          "man:samba(7)"
          "man:smb.conf(5)"
        ];

        environment.LD_LIBRARY_PATH = config.system.nssModules.path;
        partOf = [ "samba.target" ];
        restartTriggers = [ configFile ];

        serviceConfig = {
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          ExecStart = "${cfg.package}/sbin/smbd --foreground --no-process-group ${lib.escapeShellArgs cfg.smbd.extraArgs}";
          LimitCORE = "infinity";
          LimitNOFILE = 16384;
          PIDFile = "/run/samba/smbd.pid";
          Slice = "system-samba.slice";
          Type = "notify";
        };

        unitConfig.RequiresMountsFor = "/var/lib/samba";
        wantedBy = [ "samba.target" ];
        wants = [ "network-online.target" ];
      };
    })

    (lib.mkIf (cfg.enable && cfg.winbindd.enable) {
      systemd.services.samba-winbindd = {
        after = [
          "network.target"
        ]
        ++ lib.optionals (cfg.nmbd.enable) [
          "samba-nmbd.service"
        ];

        description = "Samba Winbind Daemon";

        documentation = [
          "man:winbindd(8)"
          "man:samba(7)"
          "man:smb.conf(5)"
        ];

        environment.LD_LIBRARY_PATH = config.system.nssModules.path;
        partOf = [ "samba.target" ];
        restartTriggers = [ configFile ];

        serviceConfig = {
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          ExecStart = "${cfg.package}/sbin/winbindd --foreground --no-process-group ${lib.escapeShellArgs cfg.winbindd.extraArgs}";
          LimitCORE = "infinity";
          PIDFile = "/run/samba/winbindd.pid";
          Slice = "system-samba.slice";
          Type = "notify";
        };

        unitConfig.RequiresMountsFor = "/var/lib/samba";
        wantedBy = [ "samba.target" ];
      };
    })

    (lib.mkIf (cfg.enable && cfg.usershares.enable) {
      # set some reasonable defaults
      services.samba.settings.global = lib.mkDefault {
        "usershare allow guests" = true;
        "usershare max shares" = 100; # high enough to be considered ~unlimited
        "usershare path" = "/var/lib/samba/usershares";
      };

      systemd.tmpfiles.settings."50-samba-usershares"."/var/lib/samba/usershares".d = {
        group = cfg.usershares.group;
        mode = "1775"; # sticky so users can't delete others' shares
        user = "root";
      };

      users.groups.${cfg.usershares.group} = { };
    })
  ];

  meta = {
    doc = ./samba.md;
    maintainers = [ lib.maintainers.anthonyroussel ];
  };
}
