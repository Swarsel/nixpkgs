{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.kubo;

  settingsFormat = pkgs.formats.json { };

  defaultConfig =
    pkgs.runCommand "kubo-default-config"
      {
        nativeBuildInputs = [
          cfg.package
          pkgs.jq
        ];
      }
      ''
        export IPFS_PATH="$TMPDIR"
        ipfs init --empty-repo --profile=${profile}
        # Remove the variable key to make the result deterministic.
        ipfs --offline config show | jq 'del(.Identity)' > $out
      '';

  configFile = settingsFormat.generate "kubo-config.json" cfg.settings;

  # Create a fake repo containing only the file "api".
  # $IPFS_PATH will point to this directory instead of the real one.
  # For some reason the Kubo CLI tools insist on reading the
  # config file when it exists. But the Kubo daemon sets the file
  # permissions such that only the ipfs user is allowed to read
  # this file. This prevents normal users from talking to the daemon.
  # To work around this terrible design, create a fake repo with no
  # config file, only an api file and everything should work as expected.
  fakeKuboRepo = pkgs.writeTextDir "api" ''
    /unix/run/ipfs.sock
  '';

  kuboFlags = utils.escapeSystemdExecArgs (
    lib.optional cfg.autoMount "--mount"
    ++ lib.optional cfg.enableGC "--enable-gc"
    ++ lib.optional (cfg.serviceFdlimit != null) "--manage-fdlimit=false"
    ++ lib.optional (cfg.defaultMode == "offline") "--offline"
    ++ lib.optional (cfg.defaultMode == "norouting") "--routing=none"
    ++ cfg.extraFlags
  );

  profile = if cfg.localDiscovery then "local-discovery" else "server";

  splitMulitaddr = addrRaw: lib.tail (lib.splitString "/" addrRaw);

  multiaddrsToListenStreams =
    addrIn:
    let
      addrs = if builtins.isList addrIn then addrIn else [ addrIn ];
      unfilteredResult = map multiaddrToListenStream addrs;
    in
    builtins.filter (addr: addr != null) unfilteredResult;

  multiaddrsToListenDatagrams =
    addrIn:
    let
      addrs = if builtins.isList addrIn then addrIn else [ addrIn ];
      unfilteredResult = map multiaddrToListenDatagram addrs;
    in
    builtins.filter (addr: addr != null) unfilteredResult;

  multiaddrToListenStream =
    addrRaw:
    let
      addr = splitMulitaddr addrRaw;
      s = builtins.elemAt addr;
    in
    if s 0 == "ip4" && s 2 == "tcp" then
      "${s 1}:${s 3}"
    else if s 0 == "ip6" && s 2 == "tcp" then
      "[${s 1}]:${s 3}"
    else if s 0 == "unix" then
      "/${lib.concatStringsSep "/" (lib.tail addr)}"
    else
      null; # not valid for listen stream, skip

  multiaddrToListenDatagram =
    addrRaw:
    let
      addr = splitMulitaddr addrRaw;
      s = builtins.elemAt addr;
    in
    if s 0 == "ip4" && s 2 == "udp" then
      "${s 1}:${s 3}"
    else if s 0 == "ip6" && s 2 == "udp" then
      "[${s 1}]:${s 3}"
    else
      null; # not valid for listen datagram, skip

in
{

  imports = [
    (lib.mkRenamedOptionModule [ "services" "ipfs" "enable" ] [ "services" "kubo" "enable" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "package" ] [ "services" "kubo" "package" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "user" ] [ "services" "kubo" "user" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "group" ] [ "services" "kubo" "group" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "dataDir" ] [ "services" "kubo" "dataDir" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "defaultMode" ] [ "services" "kubo" "defaultMode" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "autoMount" ] [ "services" "kubo" "autoMount" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "autoMigrate" ] [ "services" "kubo" "autoMigrate" ])
    (lib.mkRenamedOptionModule
      [ "services" "ipfs" "ipfsMountDir" ]
      [ "services" "kubo" "settings" "Mounts" "IPFS" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "ipfs" "ipnsMountDir" ]
      [ "services" "kubo" "settings" "Mounts" "IPNS" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "ipfs" "gatewayAddress" ]
      [ "services" "kubo" "settings" "Addresses" "Gateway" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "ipfs" "apiAddress" ]
      [ "services" "kubo" "settings" "Addresses" "API" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "ipfs" "swarmAddress" ]
      [ "services" "kubo" "settings" "Addresses" "Swarm" ]
    )
    (lib.mkRenamedOptionModule [ "services" "ipfs" "enableGC" ] [ "services" "kubo" "enableGC" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "emptyRepo" ] [ "services" "kubo" "emptyRepo" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "extraConfig" ] [ "services" "kubo" "settings" ])
    (lib.mkRenamedOptionModule [ "services" "ipfs" "extraFlags" ] [ "services" "kubo" "extraFlags" ])
    (lib.mkRenamedOptionModule
      [ "services" "ipfs" "localDiscovery" ]
      [ "services" "kubo" "localDiscovery" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "ipfs" "serviceFdlimit" ]
      [ "services" "kubo" "serviceFdlimit" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "ipfs" "startWhenNeeded" ]
      [ "services" "kubo" "startWhenNeeded" ]
    )
    (lib.mkRenamedOptionModule [ "services" "kubo" "extraConfig" ] [ "services" "kubo" "settings" ])
    (lib.mkRenamedOptionModule
      [ "services" "kubo" "gatewayAddress" ]
      [ "services" "kubo" "settings" "Addresses" "Gateway" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "kubo" "apiAddress" ]
      [ "services" "kubo" "settings" "Addresses" "API" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "kubo" "swarmAddress" ]
      [ "services" "kubo" "settings" "Addresses" "Swarm" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "kubo" "ipfsMountDir" ]
      [ "services" "kubo" "settings" "Mounts" "IPFS" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "kubo" "ipnsMountDir" ]
      [ "services" "kubo" "settings" "Mounts" "IPNS" ]
    )
  ];

  ###### interface
  options = {

    services.kubo = {

      enable = lib.mkEnableOption ''
        the Interplanetary File System (WARNING: may cause severe network degradation).
        NOTE: after enabling this option and rebuilding your system, you need to log out
        and back in for the `IPFS_PATH` environment variable to be present in your shell.
        Until you do that, the CLI tools won't be able to talk to the daemon by default
      '';

      package = lib.mkPackageOption pkgs "kubo" { };

      autoMigrate = lib.mkOption {
        default = true;
        description = "Whether Kubo should try to migrate its filesystem repository automatically.";
        type = lib.types.bool;
      };

      autoMount = lib.mkOption {
        default = false;
        description = "Whether Kubo should try to mount /ipfs, /ipns and /mfs at startup.";
        type = lib.types.bool;
      };

      dataDir = lib.mkOption {
        default =
          if lib.versionAtLeast config.system.stateVersion "17.09" then
            "/var/lib/ipfs"
          else
            "/var/lib/ipfs/.ipfs";

        defaultText = lib.literalExpression ''
          if lib.versionAtLeast config.system.stateVersion "17.09"
          then "/var/lib/ipfs"
          else "/var/lib/ipfs/.ipfs"
        '';

        description = "The data dir for Kubo";
        type = lib.types.str;
      };

      defaultMode = lib.mkOption {
        default = "online";
        description = "systemd service that is enabled by default";

        type = lib.types.enum [
          "online"
          "offline"
          "norouting"
        ];
      };

      emptyRepo = lib.mkOption {
        default = true;
        description = "If set to false, the repo will be initialized with help files";
        type = lib.types.bool;
      };

      enableGC = lib.mkOption {
        default = false;
        description = "Whether to enable automatic garbage collection";
        type = lib.types.bool;
      };

      extraFlags = lib.mkOption {
        default = [ ];
        description = "Extra flags passed to the Kubo daemon";
        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = "ipfs";
        description = "Group under which the Kubo daemon runs";
        type = lib.types.str;
      };

      localDiscovery = lib.mkOption {
        default = false;

        description = ''
          Whether to enable local discovery for the Kubo daemon.
                    This will allow Kubo to scan ports on your local network. Some hosting services will ban you if you do this.
        '';

        type = lib.types.bool;
      };

      serviceFdlimit = lib.mkOption {
        default = null;
        description = "The fdlimit for the Kubo systemd unit or `null` to have the daemon attempt to manage it";
        example = 64 * 1024;
        type = lib.types.nullOr lib.types.int;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Attrset of daemon configuration.
          See [https://github.com/ipfs/kubo/blob/master/docs/config.md](https://github.com/ipfs/kubo/blob/master/docs/config.md) for reference.
          You can't set `Identity` or `Pinning`.
        '';

        example = {
          Bootstrap = [
            "/ip4/128.199.219.111/tcp/4001/ipfs/QmSoLSafTMBsPKadTEgaXctDQVcqN88CNLHXMkTNwMKPnu"
            "/ip4/162.243.248.213/tcp/4001/ipfs/QmSoLueR4xBeUbY9WZ9xGUUxunbKWcrNFTDAadQJmocnWm"
          ];

          Datastore.StorageMax = "100GB";
          Discovery.MDNS.Enabled = false;
          Swarm.AddrFilters = null;
        };

        type = lib.types.submodule {
          options = {
            Addresses.API = lib.mkOption {
              default = [ ];

              description = ''
                Multiaddr or array of multiaddrs describing the address to serve the local HTTP API on.
                In addition to the multiaddrs listed here, the daemon will also listen on a Unix domain socket.
                To allow the ipfs CLI tools to communicate with the daemon over that socket,
                add your user to the correct group, e.g. `users.users.alice.extraGroups = [ config.services.kubo.group ];`
              '';

              type = lib.types.oneOf [
                lib.types.str
                (lib.types.listOf lib.types.str)
              ];
            };

            Addresses.Gateway = lib.mkOption {
              default = "/ip4/127.0.0.1/tcp/8080";
              description = "Where the IPFS Gateway can be reached";

              type = lib.types.oneOf [
                lib.types.str
                (lib.types.listOf lib.types.str)
              ];
            };

            Addresses.Swarm = lib.mkOption {
              default = [
                "/ip4/0.0.0.0/tcp/4001"
                "/ip6/::/tcp/4001"
                "/ip4/0.0.0.0/udp/4001/quic-v1"
                "/ip4/0.0.0.0/udp/4001/quic-v1/webtransport"
                "/ip4/0.0.0.0/udp/4001/webrtc-direct"
                "/ip6/::/udp/4001/quic-v1"
                "/ip6/::/udp/4001/quic-v1/webtransport"
                "/ip6/::/udp/4001/webrtc-direct"
              ];

              description = "Where Kubo listens for incoming p2p connections";
              type = lib.types.listOf lib.types.str;
            };

            Mounts.FuseAllowOther = lib.mkOption {
              default = true;
              description = "Allow all users to access the FUSE mount points";
              type = lib.types.bool;
            };

            Mounts.IPFS = lib.mkOption {
              default = "/ipfs";
              description = "Where to mount the IPFS namespace to";
              type = lib.types.str;
            };

            Mounts.IPNS = lib.mkOption {
              default = "/ipns";
              description = "Where to mount the IPNS namespace to";
              type = lib.types.str;
            };

            Mounts.MFS = lib.mkOption {
              default = "/mfs";
              description = "Where to mount the MFS namespace to";
              type = lib.types.str;
            };
          };

          freeformType = settingsFormat.type;
        };

      };

      startWhenNeeded = lib.mkOption {
        default = false;
        description = "Whether to use socket activation to start Kubo when needed.";
        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "ipfs";
        description = "User under which the Kubo daemon runs";
        type = lib.types.str;
      };

    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !builtins.hasAttr "Identity" cfg.settings;

        message = ''
          You can't set services.kubo.settings.Identity because the ``config replace`` subcommand used at startup does not support modifying any of the Identity settings.
        '';
      }
      {
        assertion =
          !(
            (builtins.hasAttr "Pinning" cfg.settings)
            && (builtins.hasAttr "RemoteServices" cfg.settings.Pinning)
          );

        message = ''
          You can't set services.kubo.settings.Pinning.RemoteServices because the ``config replace`` subcommand used at startup does not work with it.
        '';
      }
      {
        assertion =
          !(
            (lib.versionAtLeast cfg.package.version "0.21")
            && (builtins.hasAttr "Experimental" cfg.settings)
            && (builtins.hasAttr "AcceleratedDHTClient" cfg.settings.Experimental)
          );

        message = ''
          The `services.kubo.settings.Experimental.AcceleratedDHTClient` option was renamed to `services.kubo.settings.Routing.AcceleratedDHTClient` in Kubo 0.21.
        '';
      }
    ];

    # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
    boot.kernel.sysctl."net.core.rmem_max" = lib.mkDefault 7500000;
    boot.kernel.sysctl."net.core.wmem_max" = lib.mkDefault 7500000;
    environment.systemPackages = [ cfg.package ];
    environment.variables.IPFS_PATH = fakeKuboRepo;

    programs.fuse = {
      enable = lib.mkIf cfg.autoMount true;
      userAllowOther = lib.mkIf cfg.settings.Mounts.FuseAllowOther true;
    };

    # The hardened systemd unit breaks the fuse-mount function according to documentation in the unit file itself
    systemd.packages =
      if cfg.autoMount then [ cfg.package.systemd_unit ] else [ cfg.package.systemd_unit_hardened ];

    systemd.services.ipfs = {
      environment.IPFS_PATH = cfg.dataDir;

      path = [
        "/run/wrappers"
        cfg.package
        pkgs.kubo-fs-repo-migrations # Used by 'ipfs repo migrate --to=...'
      ];

      postStop = lib.mkIf cfg.autoMount ''
        # After an unclean shutdown the fuse mounts at cfg.settings.Mounts.IPFS, cfg.settings.Mounts.IPNS and cfg.settings.Mounts.MFS are locked
        umount --quiet '${cfg.settings.Mounts.IPFS}' '${cfg.settings.Mounts.IPNS}' '${cfg.settings.Mounts.MFS}' || true
      '';

      preStart = ''
        if [[ ! -f "$IPFS_PATH/config" ]]; then
          ipfs init --empty-repo=${lib.boolToString cfg.emptyRepo}
        else
          # After an unclean shutdown this file may exist which will cause the config command to attempt to talk to the daemon. This will hang forever if systemd is holding our sockets open.
          rm -vf "$IPFS_PATH/api"
      ''
      + lib.optionalString cfg.autoMigrate ''
        '${lib.getExe cfg.package}' repo migrate '--to=${cfg.package.repoVersion}' --allow-downgrade
      ''
      + ''
        fi

        # We need the Identity and Pinning configuration from the current settings.
        ipfs --offline config show |
          ${lib.getExe pkgs.jq} '{ Identity, Pinning, }' |

          # Now we deep-merge all configuration sources (later data wins):
          # 1. the default configuration
          # 2. the user-provided configuration
          # 3. the dynamic keys from the existing configuration
          ${lib.getExe pkgs.jq} -s 'reduce .[] as $config ({}; . * $config)' \
            ${defaultConfig} \
            ${configFile} \
            - \
          |

          # This command automatically injects the private key and other secrets from
          # the old config file back into the new config file.
          # Unfortunately, it doesn't keep the original `Identity.PeerID`,
          # so we need `ipfs config show` and jq above.
          # See https://github.com/ipfs/kubo/issues/8993 for progress on fixing this problem.
          # Kubo also wants a specific version of the original "Pinning.RemoteServices"
          # section (redacted by `ipfs config show`), such that that section doesn't
          # change when the changes are applied. Whyyyyyy.....
          ipfs --offline config replace -
      '';

      serviceConfig = {
        ExecStart = [
          ""
          "${lib.getExe cfg.package} daemon ${kuboFlags}"
        ];

        Group = cfg.group;

        ReadWritePaths = lib.optionals (!cfg.autoMount) [
          ""
          cfg.dataDir
        ];

        # Make sure the socket units are started before ipfs.service
        Sockets = [
          "ipfs-gateway.socket"
          "ipfs-api.socket"
        ];

        StateDirectory = "";
        User = cfg.user;
      }
      // lib.optionalAttrs (cfg.serviceFdlimit != null) { LimitNOFILE = cfg.serviceFdlimit; };
    }
    // lib.optionalAttrs (!cfg.startWhenNeeded) {
      wantedBy = [ "default.target" ];
    };

    systemd.sockets.ipfs-api = {
      socketConfig = {
        # We also include "%t/ipfs.sock" because there is no way to put the "%t"
        # in the multiaddr.
        ListenStream = [
          ""
          "%t/ipfs.sock"
        ]
        ++ (multiaddrsToListenStreams cfg.settings.Addresses.API);

        SocketGroup = cfg.group;
        SocketMode = "0660";
        SocketUser = cfg.user;
      };

      wantedBy = [ "sockets.target" ];
    };

    systemd.sockets.ipfs-gateway = {
      socketConfig = {
        ListenDatagram = [ "" ] ++ (multiaddrsToListenDatagrams cfg.settings.Addresses.Gateway);
        ListenStream = [ "" ] ++ (multiaddrsToListenStreams cfg.settings.Addresses.Gateway);
      };

      wantedBy = [ "sockets.target" ];
    };

    systemd.tmpfiles.settings."10-kubo" =
      let
        defaultConfig = { inherit (cfg) user group; };
      in
      {
        ${cfg.dataDir}.d = defaultConfig;
        ${cfg.settings.Mounts.IPFS}.d = lib.mkIf (cfg.autoMount) defaultConfig;
        ${cfg.settings.Mounts.IPNS}.d = lib.mkIf (cfg.autoMount) defaultConfig;
        ${cfg.settings.Mounts.MFS}.d = lib.mkIf (cfg.autoMount) defaultConfig;
      };

    users.groups = lib.mkIf (cfg.group == "ipfs") {
      ipfs.gid = config.ids.gids.ipfs;
    };

    users.users = lib.mkIf (cfg.user == "ipfs") {
      ipfs = {
        createHome = false;
        description = "IPFS daemon user";
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.ipfs;
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ Luflosi ];
  };
}
