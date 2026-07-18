{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.newt;
  type =
    with lib.types;
    attrsOf (
      nullOr (oneOf [
        bool
        int
        float
        str
        path
        (listOf type)
      ])
    )
    // {
      description = "value coercible to CLI argument";
    };
  format = pkgs.formats.yaml { };
  blueprint-file = format.generate "blueprint.yml" cfg.blueprint;
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "newt" "id" ] [ "services" "newt" "settings" "id" ])
    (lib.mkRenamedOptionModule
      [ "services" "newt" "logLevel" ]
      [ "services" "newt" "settings" "log-level" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "newt" "endpoint" ]
      [ "services" "newt" "settings" "endpoint" ]
    )
  ];

  options = {
    services.newt = {
      enable = lib.mkEnableOption "Newt, user space tunnel client for Pangolin";
      package = lib.mkPackageOption pkgs "fosrl-newt" { };

      blueprint = lib.mkOption {
        inherit (format) type;
        default = { };
        description = "Blueprint for declarative settings, see [Newt Blueprint docs](https://docs.pangolin.net/manage/blueprints#blueprints) for more information.";

        example = {
          proxy-resources = {
            jellyfin = {
              auth.sso-enabled = true;
              full-domain = "jfn.example.com";
              name = "Jellyfin";
              protocol = "http";

              targets = [
                {
                  hostname = "localhost";
                  method = "http";
                  port = 8096;
                }
              ];
            };
          };
        };
      };

      # provide path to file to keep secrets out of the nix store
      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Path to a file containing sensitive environment variables for Newt. See [Client credentials](https://docs.pangolin.net/manage/clients/credentials) for more information.
          These will overwrite anything defined in the config.
          The file should contain environment-variable assignments like:
          NEWT_ID=2ix2t8xk22ubpfy
          NEWT_SECRET=nnisrfsdfc7prqsp9ewo1dvtvci50j5uiqotez00dgap0ii2
        '';

        type = with lib.types; nullOr path;
      };

      settings = lib.mkOption {
        inherit type;
        default = { };
        description = "Settings for Newt module, see [Newt CLI docs](https://github.com/fosrl/newt?tab=readme-ov-file#cli-args) for more information.";

        example = {
          endpoint = "pangolin.example.com";
          id = "8yfsghj438a20ol";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.environmentFile != null;
        message = "services.newt.environmentFile must be provided when Newt is enabled.";
      }
    ];

    systemd.services.newt = {
      after = [ "network.target" ];
      description = "Newt, user space tunnel client for Pangolin";

      environment = {
        HOME = "/var/lib/private/newt";
      };

      serviceConfig = {
        CapabilityBoundingSet = [
          "~CAP_BLOCK_SUSPEND"
          "~CAP_BPF"
          "~CAP_CHOWN"
          "~CAP_MKNOD"
          "~CAP_NET_RAW"
          "~CAP_PERFMON"
          "~CAP_SYS_BOOT"
          "~CAP_SYS_CHROOT"
          "~CAP_SYS_MODULE"
          "~CAP_SYS_NICE"
          "~CAP_SYS_PACCT"
          "~CAP_SYS_PTRACE"
          "~CAP_SYS_TIME"
          "~CAP_SYS_TTY_CONFIG"
          "~CAP_SYSLOG"
          "~CAP_WAKE_ALARM"
        ];

        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;

        ExecStart = "${lib.getExe cfg.package} ${
          lib.cli.toCommandLineShellGNU { } (lib.recursiveUpdate cfg.settings { inherit blueprint-file; })
        }";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = "disconnected";
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        # hardening
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "always";
        RestartSec = "10s";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "newt";
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "~@aio:EPERM"
          "~@chown:EPERM"
          "~@clock:EPERM"
          "~@cpu-emulation:EPERM"
          "~@debug:EPERM"
          "~@keyring:EPERM"
          "~@memlock:EPERM"
          "~@module:EPERM"
          "~@mount:EPERM"
          "~@obsolete:EPERM"
          "~@pkey:EPERM"
          "~@privileged:EPERM"
          "~@raw-io:EPERM"
          "~@reboot:EPERM"
          "~@resources:EPERM"
          "~@sandbox:EPERM"
          "~@setuid:EPERM"
          "~@swap:EPERM"
          "~@sync:EPERM"
          "~@timer:EPERM"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ jackr ];
}
