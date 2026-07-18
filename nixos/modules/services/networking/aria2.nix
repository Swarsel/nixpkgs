{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.aria2;

  homeDir = "/var/lib/aria2";
  defaultRpcListenPort = 6800;
  defaultDir = "${homeDir}/Downloads";

  portRangesToString =
    ranges:
    lib.concatStringsSep "," (
      map (x: if x.from == x.to then toString x.from else toString x.from + "-" + toString x.to) ranges
    );

  customToKeyValue = lib.generators.toKeyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault {
      mkValueString =
        v: if builtins.isList v then portRangesToString v else lib.generators.mkValueStringDefault { } v;
    } "=";
  };
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "aria2"
      "rpcSecret"
    ] "Use services.aria2.rpcSecretFile instead")
    (lib.mkRemovedOptionModule [
      "services"
      "aria2"
      "extraArguments"
    ] "Use services.aria2.settings instead")
    (lib.mkRenamedOptionModule
      [ "services" "aria2" "downloadDir" ]
      [ "services" "aria2" "settings" "dir" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "aria2" "listenPortRange" ]
      [ "services" "aria2" "settings" "listen-port" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "aria2" "rpcListenPort" ]
      [ "services" "aria2" "settings" "rpc-listen-port" ]
    )
  ];

  options = {
    services.aria2 = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether or not to enable the headless Aria2 daemon service.

          Aria2 daemon can be controlled via the RPC interface using one of many
          WebUIs (http://localhost:${toString defaultRpcListenPort}/ by default).

          Targets are downloaded to `${defaultDir}` by default and are
          accessible to users in the `aria2` group.
        '';

        type = lib.types.bool;
      };

      downloadDirPermission = lib.mkOption {
        default = "0770";

        description = ''
          The permission for `settings.dir`.

          The default is 0770, which denies access for users not in the `aria2`
          group.

          You may want to adjust `serviceUMask` as well, which further restricts
          the file permission for newly created files (i.e. the downloads).
        '';

        type = lib.types.str;
      };

      openPorts = lib.mkOption {
        default = false;

        description = ''
          Open listen and RPC ports found in `settings.listen-port` and
          `settings.rpc-listen-port` options in the firewall.
        '';

        type = lib.types.bool;
      };

      rpcSecretFile = lib.mkOption {
        description = ''
          A file containing the RPC secret authorization token.
          Read <https://aria2.github.io/manual/en/html/aria2c.html#rpc-auth> to know how this option value is used.
        '';

        example = "/run/secrets/aria2-rpc-token.txt";
        type = lib.types.path;
      };

      serviceUMask = lib.mkOption {
        default = "0022";

        description = ''
          The file mode creation mask for Aria2 service.

          The default is 0022 for compatibility reason, as this is the default
          used by systemd. However, this results in file permission 0644 for new
          files, and denies `aria2` group member from modifying the file.

          You may want to set this value to `0002` so you can manage the file
          more easily.
        '';

        example = "0002";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Generates the {file}`aria2.conf` file. Refer to [the documentation][0] for
          all possible settings.

          [0]: <https://aria2.github.io/manual/en/html/aria2c.html#synopsis>
        '';

        type = lib.types.submodule {
          options = {
            conf-path = lib.mkOption {
              default = "${homeDir}/aria2.conf";
              description = "Configuration file path.";
              type = lib.types.singleLineStr;
            };

            dir = lib.mkOption {
              default = defaultDir;
              description = "Directory to store downloaded files.";
              type = lib.types.singleLineStr;
            };

            enable-rpc = lib.mkOption {
              default = true;
              description = "Enable JSON-RPC/XML-RPC server.";
              type = lib.types.bool;
            };

            listen-port = lib.mkOption {
              default = [
                {
                  from = 6881;
                  to = 6999;
                }
              ];

              description = "Set UDP listening port range used by DHT(IPv4, IPv6) and UDP tracker.";
              type = with lib.types; listOf (attrsOf port);
            };

            rpc-listen-port = lib.mkOption {
              default = defaultRpcListenPort;
              description = "Specify a port number for JSON-RPC/XML-RPC server to listen to. Possible Values: 1024-65535";
              type = lib.types.port;
            };

            save-session = lib.mkOption {
              default = "${homeDir}/aria2.session";
              description = "Save error/unfinished downloads to FILE on exit.";
              type = lib.types.singleLineStr;
            };
          };

          freeformType =
            with lib.types;
            attrsOf (oneOf [
              bool
              int
              float
              singleLineStr
            ]);
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.enable-rpc;
        message = "RPC has to be enabled, the default module option takes care of that.";
      }
      {
        assertion = !(cfg.settings ? rpc-secret);
        message = "Set the RPC secret through services.aria2.rpcSecretFile so it will not end up in the world-readable nix store.";
      }
    ];

    # Need to open ports for proper functioning
    networking.firewall = lib.mkIf cfg.openPorts {
      allowedTCPPorts = [ config.services.aria2.settings.rpc-listen-port ];
      allowedUDPPortRanges = config.services.aria2.settings.listen-port;
    };

    systemd.services.aria2 = {
      after = [ "network.target" ];
      description = "aria2 Service";

      preStart = ''
        if [[ ! -e "${cfg.settings.save-session}" ]]
        then
          touch "${cfg.settings.save-session}"
        fi
        cp -f "${pkgs.writeText "aria2.conf" (customToKeyValue cfg.settings)}" "${cfg.settings.conf-path}"
        chmod +w "${cfg.settings.conf-path}"
        echo "rpc-secret=$(cat "$CREDENTIALS_DIRECTORY/rpcSecretFile")" >> "${cfg.settings.conf-path}"
      '';

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.aria2}/bin/aria2c --conf-path=${cfg.settings.conf-path}";
        Group = "aria2";
        LoadCredential = "rpcSecretFile:${cfg.rpcSecretFile}";
        Restart = "on-abort";
        UMask = cfg.serviceUMask;
        User = "aria2";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${homeDir}' 0770 aria2 aria2 - -"
      "d '${config.services.aria2.settings.dir}' ${config.services.aria2.downloadDirPermission} aria2 aria2 - -"
    ];

    users.groups.aria2.gid = config.ids.gids.aria2;

    users.users.aria2 = {
      createHome = false;
      description = "aria2 user";
      group = "aria2";
      home = homeDir;
      uid = config.ids.uids.aria2;
    };
  };

  meta.maintainers = [ lib.maintainers.timhae ];
}
