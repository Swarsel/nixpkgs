{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.znc;

  defaultUser = "znc";

  modules = pkgs.buildEnv {
    name = "znc-modules";
    paths = cfg.modulePackages;
  };

  listenerPorts = concatMap (l: optional (l ? Port) l.Port) (attrValues (cfg.config.Listener or { }));

  # Converts the config option to a string
  semanticString =
    let

      sortedAttrs =
        set:
        sort (
          l: r:
          if l == "extraConfig" then
            false # Always put extraConfig last
          else if isAttrs set.${l} == isAttrs set.${r} then
            l < r
          else
            isAttrs set.${r} # Attrsets should be last, makes for a nice config
          # This last case occurs when any side (but not both) is an attrset
          # The order of these is correct when the attrset is on the right
          # which we're just returning
        ) (attrNames set);

      # Specifies an attrset that encodes the value according to its type
      encode =
        name: value:
        {
          bool = [ "${name} = ${boolToString value}" ];
          int = [ "${name} = ${toString value}" ];
          # Values like `Foo = [ "bar" "baz" ];` should be transformed into
          #   Foo=bar
          #   Foo=baz
          list = concatMap (encode name) value;
          null = [ ];

          # Values like `Foo = { bar = { Baz = "baz"; Qux = "qux"; Florps = null; }; };` should be transmed into
          #   <Foo bar>
          #     Baz=baz
          #     Qux=qux
          #   </Foo>
          set = concatMap (
            subname:
            optionals (value.${subname} != null) (
              [
                "<${name} ${subname}>"
              ]
              ++ map (line: "\t${line}") (toLines value.${subname})
              ++ [
                "</${name}>"
              ]
            )
          ) (filter (v: v != null) (attrNames value));

          # extraConfig should be inserted verbatim
          string = [ (if name == "extraConfig" then value else "${name} = ${value}") ];

        }
        .${builtins.typeOf value};

      # One level "above" encode, acts upon a set and uses encode on each name,value pair
      toLines = set: concatMap (name: encode name set.${name}) (sortedAttrs set);

    in
    concatStringsSep "\n" (toLines cfg.config);

  semanticTypes = with types; rec {
    zncAll = oneOf [
      zncAtom
      (listOf zncAtom)
      zncAttr
    ];

    zncAtom = nullOr (oneOf [
      int
      bool
      str
    ]);

    zncAttr = attrsOf (nullOr zncConf);

    zncConf = attrsOf (
      zncAll
      // {
        # Since this is a recursive type and the description by default contains
        # the description of its subtypes, infinite recursion would occur without
        # explicitly breaking this cycle
        description = "znc values (null, atoms (str, int, bool), list of atoms, or attrsets of znc values)";
      }
    );
  };

in

{

  imports = [ ./options.nix ];

  options = {
    services.znc = {
      config = mkOption {
        default = { };

        description = ''
          Configuration for ZNC, see
          <https://wiki.znc.in/Configuration> for details. The
          Nix value declared here will be translated directly to the xml-like
          format ZNC expects. This is much more flexible than the legacy options
          under {option}`services.znc.confOptions.*`, but also can't do
          any type checking.

          You can use {command}`nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.services.znc.config`
          to view the current value. By default it contains a listener for port
          5000 with SSL enabled.

          Nix attributes called `extraConfig` will be inserted
          verbatim into the resulting config file.

          If {option}`services.znc.useLegacyConfig` is turned on, the
          option values in {option}`services.znc.confOptions.*` will be
          gracefully be applied to this option.

          If you intend to update the configuration through this option, be sure
          to disable {option}`services.znc.mutable`, otherwise none of the
          changes here will be applied after the initial deploy.
        '';

        example = literalExpression ''
          {
            LoadModule = [ "webadmin" "adminlog" ];
            User.paul = {
              Admin = true;
              Nick = "paul";
              AltNick = "paul1";
              LoadModule = [ "chansaver" "controlpanel" ];
              Network.libera = {
                Server = "irc.libera.chat +6697";
                LoadModule = [ "simple_away" ];
                Chan = {
                  "#nixos" = { Detached = false; };
                  "##linux" = { Disabled = true; };
                };
              };
              Pass.password = {
                Method = "sha256";
                Hash = "e2ce303c7ea75c571d80d8540a8699b46535be6a085be3414947d638e48d9e93";
                Salt = "l5Xryew4g*!oa(ECfX2o";
              };
            };
          }
        '';

        type = semanticTypes.zncConf;
      };

      enable = mkEnableOption "ZNC";

      configFile = mkOption {
        description = ''
          Configuration file for ZNC. It is recommended to use the
          {option}`config` option instead.

          Setting this option will override any auto-generated config file
          through the {option}`confOptions` or {option}`config`
          options.
        '';

        example = literalExpression "~/.znc/configs/znc.conf";
        type = types.path;
      };

      dataDir = mkOption {
        default = "/var/lib/znc";

        description = ''
          The state directory for ZNC. The config and the modules will be linked
          to from this directory as well.
        '';

        example = "/home/john/.znc";
        type = types.path;
      };

      extraFlags = mkOption {
        default = [ ];

        description = ''
          Extra arguments to use for executing znc.
        '';

        example = [ "--debug" ];
        type = types.listOf types.str;
      };

      group = mkOption {
        default = defaultUser;

        description = ''
          Group to own the ZNC process.
        '';

        example = "users";
        type = types.str;
      };

      modulePackages = mkOption {
        default = [ ];

        description = ''
          A list of global znc module packages to add to znc.
        '';

        example = literalExpression "[ pkgs.zncModules.fish pkgs.zncModules.push ]";
        type = types.listOf types.package;
      };

      mutable = mkOption {
        default = true; # TODO: Default to true when config is set, make sure to not delete the old config if present

        description = ''
          Indicates whether to allow the contents of the
          `dataDir` directory to be changed by the user at
          run-time.

          If enabled, modifications to the ZNC configuration after its initial
          creation are not overwritten by a NixOS rebuild. If disabled, the
          ZNC configuration is rebuilt on every NixOS rebuild.

          If the user wants to manage the ZNC service using the web admin
          interface, this option should be enabled.
        '';

        type = types.bool;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to open ports in the firewall for ZNC. Does work with
          ports for listeners specified in
          {option}`services.znc.config.Listener`.
        '';

        type = types.bool;
      };

      user = mkOption {
        default = "znc";

        description = ''
          The name of an existing user account to use to own the ZNC server
          process. If not specified, a default user will be created.
        '';

        example = "john";
        type = types.str;
      };
    };
  };

  ###### Implementation

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall listenerPorts;

    services.znc = {
      config = {
        Listener.l.Port = mkDefault 5000;
        Listener.l.SSL = mkDefault true;
        Version = lib.getVersion pkgs.znc;
      };

      configFile = mkDefault (pkgs.writeText "znc-generated.conf" semanticString);
    };

    systemd.services.znc = {
      after = [ "network-online.target" ];
      description = "ZNC Server";

      preStart = ''
        mkdir -p ${cfg.dataDir}/configs

        # If mutable, regenerate conf file every time.
        ${optionalString (!cfg.mutable) ''
          echo "znc is set to be system-managed. Now deleting old znc.conf file to be regenerated."
          rm -f ${cfg.dataDir}/configs/znc.conf
        ''}

        # Ensure essential files exist.
        if [[ ! -f ${cfg.dataDir}/configs/znc.conf ]]; then
            echo "No znc.conf file found in ${cfg.dataDir}. Creating one now."
            cp --no-preserve=ownership --no-clobber ${cfg.configFile} ${cfg.dataDir}/configs/znc.conf
            chmod u+rw ${cfg.dataDir}/configs/znc.conf
        fi

        if [[ ! -f ${cfg.dataDir}/znc.pem ]]; then
          echo "No znc.pem file found in ${cfg.dataDir}. Creating one now."
          ${pkgs.znc}/bin/znc --makepem --datadir ${cfg.dataDir}
        fi

        # Symlink modules
        rm ${cfg.dataDir}/modules || true
        ln -fs ${modules}/lib/znc ${cfg.dataDir}/modules
      '';

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.znc}/bin/znc --foreground --datadir ${cfg.dataDir} ${escapeShellArgs cfg.extraFlags}";
        ExecStop = "${pkgs.coreutils}/bin/kill -INT $MAINPID";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.dataDir ];
        RemoveIPC = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0027";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        gid = config.ids.gids.znc;
        members = [ defaultUser ];
      };
    };

    users.users = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        createHome = true;
        description = "ZNC server daemon owner";
        group = defaultUser;
        home = cfg.dataDir;
        uid = config.ids.uids.znc;
      };
    };

  };
}
