{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.openbao;

  settingsFormat = pkgs.formats.json { };
in
{
  options = {
    services.openbao = {
      enable = lib.mkEnableOption "OpenBao daemon";

      package = lib.mkPackageOption pkgs "openbao" {
        example = "pkgs.openbao.override { withHsm = false; withUi = false; }";
      };

      extraArgs = lib.mkOption {
        default = [ ];

        description = ''
          Additional arguments given to OpenBao.
        '';

        type = lib.types.listOf lib.types.str;
      };

      settings = lib.mkOption {
        description = ''
          Settings of OpenBao.

          See [documentation](https://openbao.org/docs/configuration) for more details.
        '';

        example = lib.literalExpression ''
          {
            ui = true;

            listener.default = {
              type = "tcp";
              tls_acme_email = config.security.acme.defaults.email;
              tls_acme_domains = [ "example.com" ];
              tls_acme_disable_http_challenge = true;
            };

            cluster_addr = "http://127.0.0.1:8201";
            api_addr = "https://example.com";

            storage.raft.path = "/var/lib/openbao";
          }
        '';

        type = lib.types.submodule {
          options = {
            listener = lib.mkOption {
              description = ''
                Configure a listener for responding to requests.
              '';

              type = lib.types.attrsOf (
                lib.types.submodule (
                  { config, ... }:
                  {
                    options = {
                      address = lib.mkOption {
                        default = if config.type == "unix" then "/run/openbao/openbao.sock" else "127.0.0.1:8200";
                        defaultText = lib.literalExpression ''if config.services.openbao.settings.listener.<name>.type == "unix" then "/run/openbao/openbao.sock" else "127.0.0.1:8200"'';

                        description = ''
                          The TCP address or UNIX socket path to listen on.
                        '';

                        type = lib.types.str;
                      };

                      type = lib.mkOption {
                        description = ''
                          The listener type to enable.
                        '';

                        type = lib.types.enum [
                          "tcp"
                          "unix"
                        ];
                      };
                    };

                    freeformType = settingsFormat.type;
                  }
                )
              );
            };

            ui = lib.mkEnableOption "the OpenBao web UI";
          };

          freeformType = settingsFormat.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.openbao = {
      after = [ "network.target" ];
      description = "OpenBao - A tool for managing secrets";
      restartIfChanged = false; # do not restart on "nixos-rebuild switch". It would seal the storage and disrupt the clients.

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -SIGHUP $MAINPID";

        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "server"
            "-config"
            (settingsFormat.generate "openbao.hcl.json" cfg.settings)
          ]
          ++ cfg.extraArgs
        );

        Group = "openbao";
        LimitCORE = 0;
        LockPersonality = true;
        MemorySwapMax = 0;
        MemoryZSwapMax = 0;
        PrivateUsers = "identity";
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "openbao";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "openbao";
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@resources"
          "~@privileged"
          "@chown"
        ];

        Type = "notify";
        UMask = "0077";
        User = "openbao";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
