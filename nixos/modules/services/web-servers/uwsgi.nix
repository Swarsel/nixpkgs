{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.uwsgi;

  isEmperor = cfg.instance.type == "emperor";

  imperialPowers = [
    # spawn other user processes
    "CAP_SETUID"
    "CAP_SETGID"
    "CAP_SYS_CHROOT"
    # transfer capabilities
    "CAP_SETPCAP"
    # create other user sockets
    "CAP_CHOWN"
  ];

  buildCfg =
    name: c:
    let
      plugins' =
        if any (n: !any (m: m == n) cfg.plugins) (c.plugins or [ ]) then
          throw "`plugins` attribute in uWSGI configuration contains plugins not in config.services.uwsgi.plugins"
        else
          c.plugins or cfg.plugins;
      plugins = unique plugins';

      hasPython3 = filter (n: n == "python3") plugins != [ ];
      python = if hasPython3 then cfg.package.python3 else null;

      pythonEnv = python.withPackages (c.pythonPackages or (self: [ ]));

      uwsgiCfg = {
        uwsgi =
          if c.type == "normal" then
            {
              inherit plugins;
            }
            // removeAttrs c [
              "type"
              "pythonPackages"
            ]
            // optionalAttrs (python != null) {
              env =
                # Argh, uwsgi expects list of key-values there instead of a dictionary.
                let
                  envs = partition (hasPrefix "PATH=") (c.env or [ ]);
                  oldPaths = map (x: substring (stringLength "PATH=") (stringLength x) x) envs.right;
                  paths = oldPaths ++ [ "${pythonEnv}/bin" ];
                in
                [ "PATH=${concatStringsSep ":" paths}" ] ++ envs.wrong;

              pyhome = "${pythonEnv}";
            }
          else if isEmperor then
            {
              emperor =
                if builtins.typeOf c.vassals != "set" then
                  c.vassals
                else
                  pkgs.buildEnv {
                    name = "vassals";
                    paths = mapAttrsToList buildCfg c.vassals;
                  };
            }
            // removeAttrs c [
              "type"
              "vassals"
            ]
          else
            throw "`type` attribute in uWSGI configuration should be either 'normal' or 'emperor'";
      };

    in
    pkgs.writeTextDir "${name}.json" (builtins.toJSON uwsgiCfg);

in
{

  options = {
    services.uwsgi = {

      enable = mkOption {
        default = false;
        description = "Enable uWSGI";
        type = types.bool;
      };

      package = mkOption {
        internal = true;
        type = types.package;
      };

      capabilities = mkOption {
        apply = caps: caps ++ optionals isEmperor imperialPowers;
        default = [ ];

        description = ''
          Grant capabilities to the uWSGI instance. See the
          {manpage}`capabilities(7)` for available values.

          ::: {.note}
          uWSGI runs as an unprivileged user (even as Emperor) with the minimal
          capabilities required. This option can be used to add fine-grained
          permissions without running the service as root.

          When in Emperor mode, any capability to be inherited by a vassal must
          be specified again in the vassal configuration using `cap`.
          See the uWSGI [docs](https://uwsgi-docs.readthedocs.io/en/latest/Capabilities.html)
          for more information.
          :::
        '';

        example = literalExpression ''
          [
            "CAP_NET_BIND_SERVICE" # bind on ports <1024
            "CAP_NET_RAW"          # open raw sockets
          ]
        '';

        type = types.listOf types.str;
      };

      group = mkOption {
        default = "uwsgi";
        description = "Group account under which uWSGI runs.";
        type = types.str;
      };

      instance = mkOption {
        default = {
          type = "normal";
        };

        description = ''
          uWSGI configuration. It awaits an attribute `type` inside which can be either
          `normal` or `emperor`.

          For `normal` mode you can specify `pythonPackages` as a function
          from libraries set into a list of libraries. `pythonpath` will be set accordingly.

          For `emperor` mode, you should use `vassals` attribute
          which should be either a set of names and configurations or a path to a directory.

          Other attributes will be used in configuration file as-is. Notice that you can redefine
          `plugins` setting here.
        '';

        example = literalExpression ''
          {
            type = "emperor";
            vassals = {
              moin = {
                type = "normal";
                pythonPackages = self: with self; [ moinmoin ];
                socket = "''${config.services.uwsgi.runDir}/uwsgi.sock";
              };
            };
          }
        '';

        type =
          with types;
          let
            valueType =
              nullOr (oneOf [
                bool
                int
                float
                str
                (lazyAttrsOf valueType)
                (listOf valueType)
                (mkOptionType {
                  check = x: isFunction x;
                  description = "function";
                  merge = mergeOneOption;
                  name = "function";
                })
              ])
              // {
                description = "Json value or lambda";
                emptyValue.value = { };
              };
          in
          valueType;
      };

      plugins = mkOption {
        default = [ ];
        description = "Plugins used with uWSGI";
        type = types.listOf types.str;
      };

      runDir = mkOption {
        default = "/run/uwsgi";
        description = "Where uWSGI communication sockets can live";
        type = types.path;
      };

      user = mkOption {
        default = "uwsgi";
        description = "User account under which uWSGI runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    services.uwsgi.package = pkgs.uwsgi.override {
      plugins = unique cfg.plugins;
    };

    systemd.services.uwsgi = {
      serviceConfig = {
        AmbientCapabilities = cfg.capabilities;
        CapabilityBoundingSet = cfg.capabilities;
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/uwsgi --json ${buildCfg "server" cfg.instance}/server.json";
        ExecStop = "${pkgs.coreutils}/bin/kill -INT $MAINPID";
        Group = cfg.group;
        KillSignal = "SIGQUIT";
        NotifyAccess = "main";
        RuntimeDirectory = mkIf (cfg.runDir == "/run/uwsgi") "uwsgi";
        Type = "notify";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = optional (cfg.runDir != "/run/uwsgi") ''
      d ${cfg.runDir} 775 ${cfg.user} ${cfg.group}
    '';

    users.groups = optionalAttrs (cfg.group == "uwsgi") {
      uwsgi.gid = config.ids.gids.uwsgi;
    };

    users.users = optionalAttrs (cfg.user == "uwsgi") {
      uwsgi = {
        group = cfg.group;
        uid = config.ids.uids.uwsgi;
      };
    };
  };
}
