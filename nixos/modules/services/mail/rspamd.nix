{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let

  cfg = config.services.rspamd;
  opt = options.services.rspamd;
  postfixCfg = config.services.postfix;

  bindSocketOpts =
    { config, options, ... }:
    {
      options = {
        group = mkOption {
          default = "${cfg.group}";
          description = "Group to set on unix socket";
          type = types.str;
        };

        mode = mkOption {
          default = "0644";
          description = "Mode to set on unix socket";
          type = types.str;
        };

        owner = mkOption {
          default = "${cfg.user}";
          description = "Owner to set on unix socket";
          type = types.str;
        };

        rawEntry = mkOption {
          internal = true;
          type = types.str;
        };

        socket = mkOption {
          description = ''
            Socket for this worker to listen on in a format acceptable by rspamd.
          '';

          example = "localhost:11333";
          type = types.str;
        };
      };

      config.rawEntry =
        let
          maybeOption = option: optionalString options.${option}.isDefined " ${option}=${config.${option}}";
        in
        if (!(hasPrefix "/" config.socket)) then
          "${config.socket}"
        else
          "${config.socket}${maybeOption "mode"}${maybeOption "owner"}${maybeOption "group"}";
    };

  traceWarning = w: x: builtins.trace "[1;31mwarning: ${w}[0m" x;

  workerOpts =
    { options, name, ... }:
    {
      options = {
        enable = mkOption {
          default = null;
          description = "Whether to run the rspamd worker.";
          type = types.nullOr types.bool;
        };

        bindSockets = mkOption {
          apply =
            value:
            map (
              each:
              if (isString each) then
                if (isUnixSocket each) then
                  {
                    group = cfg.group;
                    mode = "0644";
                    owner = cfg.user;
                    rawEntry = "${each}";
                    socket = each;
                  }
                else
                  {
                    rawEntry = "${each}";
                    socket = each;
                  }
              else
                each
            ) value;

          default = [ ];

          description = ''
            List of sockets to listen, in format acceptable by rspamd
          '';

          example = [
            {
              mode = "0666";
              owner = "rspamd";
              socket = "/run/rspamd.sock";
            }
            "*:11333"
          ];

          type = types.listOf (types.either types.str (types.submodule bindSocketOpts));
        };

        count = mkOption {
          default = null;

          description = ''
            Number of worker instances to run
          '';

          type = types.nullOr types.int;
        };

        extraConfig = mkOption {
          default = "";
          description = "Additional entries to put verbatim into worker section of rspamd config file.";
          type = types.lines;
        };

        includes = mkOption {
          default = [ ];

          description = ''
            List of files to include in configuration
          '';

          type = types.listOf types.str;
        };

        name = mkOption {
          default = name;
          description = "Name of the worker";
          type = types.nullOr types.str;
        };

        type = mkOption {
          apply =
            let
              from = "services.rspamd.workers.\"${name}\".type";
              files = options.type.files;
              warning = "The option `${from}` defined in ${showFiles files} has enum value `proxy` which has been renamed to `rspamd_proxy`";
            in
            x: if x == "proxy" then traceWarning warning "rspamd_proxy" else x;

          description = ''
            The type of this worker. The type `proxy` is
            deprecated and only kept for backwards compatibility and should be
            replaced with `rspamd_proxy`.
          '';

          type = types.nullOr (
            types.enum [
              "normal"
              "controller"
              "fuzzy"
              "rspamd_proxy"
              "lua"
              "proxy"
            ]
          );
        };
      };

      config =
        mkIf (name == "normal" || name == "controller" || name == "fuzzy" || name == "rspamd_proxy")
          {
            bindSockets =
              let
                unixSocket = name: {
                  group = cfg.group;
                  mode = "0660";
                  owner = cfg.user;
                  socket = "/run/rspamd/${name}.sock";
                };
              in
              mkDefault (
                if name == "normal" then
                  [ (unixSocket "rspamd") ]
                else if name == "controller" then
                  [ "localhost:11334" ]
                else if name == "rspamd_proxy" then
                  [ (unixSocket "proxy") ]
                else
                  [ ]
              );

            includes = mkDefault [ "$CONFDIR/worker-${if name == "rspamd_proxy" then "proxy" else name}.inc" ];
            type = mkDefault name;
          };
    };

  isUnixSocket = socket: hasPrefix "/" (if (isString socket) then socket else socket.socket);

  mkBindSockets =
    enabled: socks:
    concatStringsSep "\n  " (flatten (map (each: "bind_socket = \"${each.rawEntry}\";") socks));

  rspamdConfFile = pkgs.writeText "rspamd.conf" ''
    .include "$CONFDIR/common.conf"

    options {
      pidfile = "$RUNDIR/rspamd.pid";
      .include "$CONFDIR/options.inc"
      .include(try=true; priority=1,duplicate=merge) "$LOCAL_CONFDIR/local.d/options.inc"
      .include(try=true; priority=10) "$LOCAL_CONFDIR/override.d/options.inc"
    }

    logging {
      type = "syslog";
      .include "$CONFDIR/logging.inc"
      .include(try=true; priority=1,duplicate=merge) "$LOCAL_CONFDIR/local.d/logging.inc"
      .include(try=true; priority=10) "$LOCAL_CONFDIR/override.d/logging.inc"
    }

    ${concatStringsSep "\n" (
      mapAttrsToList (
        name: value:
        let
          includeName = if name == "rspamd_proxy" then "proxy" else name;
          tryOverride = boolToString (value.extraConfig == "");
        in
        ''
          worker "${value.type}" {
            type = "${value.type}";
            ${optionalString (value.enable != null) "enabled = ${lib.boolToYesNo (value.enable != false)};"}
            ${mkBindSockets value.enable value.bindSockets}
            ${optionalString (value.count != null) "count = ${toString value.count};"}
            ${concatStringsSep "\n  " (map (each: ".include \"${each}\"") value.includes)}
            .include(try=true; priority=1,duplicate=merge) "$LOCAL_CONFDIR/local.d/worker-${includeName}.inc"
            .include(try=${tryOverride}; priority=10) "$LOCAL_CONFDIR/override.d/worker-${includeName}.inc"
          }
        ''
      ) cfg.workers
    )}

    ${optionalString (cfg.extraConfig != "") ''
      .include(priority=10) "$LOCAL_CONFDIR/override.d/extra-config.inc"
    ''}
  '';

  filterFiles = files: filterAttrs (n: v: v.enable) files;
  rspamdDir = pkgs.linkFarm "etc-rspamd-dir" (
    (mapAttrsToList (name: file: {
      name = "local.d/${name}";
      path = file.source;
    }) (filterFiles cfg.locals))
    ++ (mapAttrsToList (name: file: {
      name = "override.d/${name}";
      path = file.source;
    }) (filterFiles cfg.overrides))
    ++ (optional (cfg.localLuaRules != null) {
      name = "rspamd.local.lua";
      path = cfg.localLuaRules;
    })
    ++ [
      {
        name = "rspamd.conf";
        path = rspamdConfFile;
      }
    ]
  );

  configFileModule =
    prefix:
    { config, name, ... }:
    {
      options = {
        enable = mkOption {
          default = true;

          description = ''
            Whether this file ${prefix} should be generated.  This
            option allows specific ${prefix} files to be disabled.
          '';

          type = types.bool;
        };

        source = mkOption {
          description = "Path of the source file.";
          type = types.path;
        };

        text = mkOption {
          default = null;
          description = "Text of the file.";
          type = types.nullOr types.lines;
        };
      };

      config = {
        source = mkIf (config.text != null) (
          let
            name' = "rspamd-${prefix}-" + baseNameOf name;
          in
          mkDefault (pkgs.writeText name' config.text)
        );
      };
    };

  configOverrides =
    (mapAttrs' (
      n: v:
      nameValuePair "worker-${if n == "rspamd_proxy" then "proxy" else n}.inc" {
        text = v.extraConfig;
      }
    ) (filterAttrs (n: v: v.extraConfig != "") cfg.workers))
    // (lib.optionalAttrs (cfg.extraConfig != "") {
      "extra-config.inc".text = cfg.extraConfig;
    });
in

{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "rspamd"
      "socketActivation"
    ] "Socket activation never worked correctly and could at this time not be fixed and so was removed")
    (mkRenamedOptionModule
      [ "services" "rspamd" "bindSocket" ]
      [ "services" "rspamd" "workers" "normal" "bindSockets" ]
    )
    (mkRenamedOptionModule
      [ "services" "rspamd" "bindUISocket" ]
      [ "services" "rspamd" "workers" "controller" "bindSockets" ]
    )
    (mkRemovedOptionModule [
      "services"
      "rmilter"
    ] "Use services.rspamd.* instead to set up milter service")
  ];

  ###### interface
  options = {

    services.rspamd = {
      enable = mkEnableOption "rspamd, the Rapid spam filtering system";
      package = lib.mkPackageOption pkgs "rspamd" { };

      debug = mkOption {
        default = false;
        description = "Whether to run the rspamd daemon in debug mode.";
        type = types.bool;
      };

      extraArgs = mkOption {
        default = [ ];

        description = ''
          A list of extra command line arguments to pass to rspamd.
          Check `rspamd --help` for possible arguments.
        '';

        example = [
          "--var=RBL_API_KEY=\${RBL_API_KEY}"
        ];

        type = types.listOf types.str;
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Extra configuration to add at the end of the rspamd configuration
          file.
        '';

        type = types.lines;
      };

      group = mkOption {
        default = "rspamd";

        description = ''
          Group to use when no root privileges are required.
        '';

        type = types.str;
      };

      localLuaRules = mkOption {
        default = null;

        description = ''
          Path of file to link to {file}`/etc/rspamd/rspamd.local.lua` for local
          rules written in Lua
        '';

        type = types.nullOr types.path;
      };

      locals = mkOption {
        default = { };

        description = ''
          Local configuration files, written into {file}`/etc/rspamd/local.d/{name}`.
        '';

        example = literalExpression ''
          { "redis.conf".source = "/nix/store/.../etc/dir/redis.conf";
            "arc.conf".text = "allow_envfrom_empty = true;";
          }
        '';

        type = with types; attrsOf (submodule (configFileModule "locals"));
      };

      overrides = mkOption {
        default = { };

        description = ''
          Overridden configuration files, written into {file}`/etc/rspamd/override.d/{name}`.
        '';

        example = literalExpression ''
          { "redis.conf".source = "/nix/store/.../etc/dir/redis.conf";
            "arc.conf".text = "allow_envfrom_empty = true;";
          }
        '';

        type = with types; attrsOf (submodule (configFileModule "overrides"));
      };

      postfix = {
        config = mkOption {
          default = {
            non_smtpd_milters = [ "unix:/run/rspamd/rspamd-milter.sock" ];
            smtpd_milters = [ "unix:/run/rspamd/rspamd-milter.sock" ];
          };

          description = ''
            Addon to postfix configuration
          '';

          type =
            with types;
            attrsOf (oneOf [
              bool
              str
              (listOf str)
            ]);
        };

        enable = mkOption {
          default = false;
          description = "Add rspamd milter to postfix main.conf";
          type = types.bool;
        };
      };

      user = mkOption {
        default = "rspamd";

        description = ''
          User to use when no root privileges are required.
        '';

        type = types.str;
      };

      workers = mkOption {
        default = {
          controller = { };
          normal = { };
        };

        description = ''
          Attribute set of workers to start.
        '';

        example = literalExpression ''
          {
            normal = {
              includes = [ "$CONFDIR/worker-normal.inc" ];
              bindSockets = [{
                socket = "/run/rspamd/rspamd.sock";
                mode = "0660";
                owner = "''${config.${opt.user}}";
                group = "''${config.${opt.group}}";
              }];
            };
            controller = {
              includes = [ "$CONFDIR/worker-controller.inc" ];
              bindSockets = [ "[::1]:11334" ];
            };
          }
        '';

        type = with types; attrsOf (submodule workerOpts);
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment.etc.rspamd.source = rspamdDir;
    # Allow users to run 'rspamc' and 'rspamadm'.
    environment.systemPackages = [ cfg.package ];
    services.postfix.settings.main = mkIf cfg.postfix.enable cfg.postfix.config;
    services.rspamd.overrides = configOverrides;

    services.rspamd.workers = mkIf cfg.postfix.enable {
      controller = { };

      rspamd_proxy = {
        bindSockets = [
          {
            group = postfixCfg.group;
            mode = "0660";
            owner = cfg.user;
            socket = "/run/rspamd/rspamd-milter.sock";
          }
        ];

        extraConfig = ''
          upstream "local" {
            default = yes; # Self-scan upstreams are always default
            self_scan = yes; # Enable self-scan
          }
        '';
      };
    };

    systemd.services.postfix = mkIf cfg.postfix.enable {
      serviceConfig.SupplementaryGroups = [ postfixCfg.group ];
    };

    systemd.services.rspamd = {
      after = [ "network.target" ];
      description = "Rspamd Service";
      restartTriggers = [ rspamdDir ];

      serviceConfig = {
        AmbientCapabilities = [ ];
        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        ExecStart = "${cfg.package}/bin/rspamd ${optionalString cfg.debug "-d"} ${escapeShellArgs cfg.extraArgs} -c /etc/rspamd/rspamd.conf -f";
        Group = "${cfg.group}";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        # we need to chown socket to rspamd-milter
        PrivateUsers = !cfg.postfix.enable;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "rspamd";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "rspamd";
        StateDirectoryMode = "0700";
        SupplementaryGroups = mkIf cfg.postfix.enable [ postfixCfg.group ];
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        UMask = "0077";
        User = "${cfg.user}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${cfg.group} = {
      gid = config.ids.gids.rspamd;
    };

    users.users.${cfg.user} = {
      description = "rspamd daemon";
      group = cfg.group;
      uid = config.ids.uids.rspamd;
    };
  };
}
