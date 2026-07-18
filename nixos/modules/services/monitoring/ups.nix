{
  config,
  lib,
  pkgs,
  ...
}:
# TODO: This is not secure, have a look at the file docs/security.txt inside
# the project sources.
let
  cfg = config.power.ups;
  defaultPort = 3493;

  envVars = {
    NUT_CONFPATH = "/etc/nut";
    NUT_STATEPATH = "/var/lib/nut";
  };

  nutFormat = {

    generate =
      name: value:
      let
        normalizedValue = lib.mapAttrs (
          key: val:
          if lib.isList val then
            lib.forEach val (elem: if lib.isList elem then elem else [ elem ])
          else if val == null then
            [ ]
          else
            [ [ val ] ]
        ) value;

        mkValueString = lib.concatMapStringsSep " " (
          v:
          let
            str = lib.generators.mkValueStringDefault { } v;
          in
          # Quote the value if it has spaces and isn't already quoted.
          if (lib.hasInfix " " str) && !(lib.hasPrefix "\"" str && lib.hasSuffix "\"" str) then
            "\"${str}\""
          else
            str
        );

      in
      pkgs.writeText name (
        lib.generators.toKeyValue {
          listsAsDuplicateKeys = true;
          mkKeyValue = lib.generators.mkKeyValueDefault { inherit mkValueString; } " ";
        } normalizedValue
      );

    type =
      with lib.types;
      let

        singleAtom =
          nullOr (oneOf [
            bool
            int
            float
            str
          ])
          // {
            description = "atom (null, bool, int, float or string)";
          };

      in
      attrsOf (oneOf [
        singleAtom
        (listOf (nonEmptyListOf singleAtom))
      ]);

  };

  installSecrets =
    source: target: owner: secrets:
    pkgs.writeShellScript "installSecrets.sh" ''
      install -m0600 -o${owner} -D ${source} "${target}"
      ${lib.concatLines (
        lib.forEach secrets (name: ''
          ${pkgs.replace-secret}/bin/replace-secret \
            '@${name}@' \
            "$CREDENTIALS_DIRECTORY/${name}" \
            "${target}"
        '')
      )}
      chmod u-w "${target}"
    '';

  upsmonConf = nutFormat.generate "upsmon.conf" cfg.upsmon.settings;

  upsdUsers = pkgs.writeText "upsd.users" (
    let
      # This looks like INI, but it's not quite because the
      # 'upsmon' option lacks a '='. See: man upsd.users
      userConfig =
        name: user:
        lib.concatStringsSep "\n      " (
          lib.concatLists [
            [
              "[${name}]"
              "password = \"@upsdusers_password_${name}@\""
            ]
            (lib.optional (user.upsmon != null) "upsmon ${user.upsmon}")
            (lib.forEach user.actions (action: "actions = ${action}"))
            (lib.forEach user.instcmds (instcmd: "instcmds = ${instcmd}"))
          ]
        );
    in
    lib.concatStringsSep "\n\n" (lib.mapAttrsToList userConfig cfg.users)
  );

  upsOptions =
    { config, name, ... }:
    {
      options = {
        description = lib.mkOption {
          default = "";

          description = ''
            Description of the UPS.
          '';

          type = lib.types.str;
        };

        directives = lib.mkOption {
          default = [ ];

          description = ''
            List of configuration directives for this UPS.
          '';

          type = lib.types.listOf lib.types.str;
        };

        # This can be inferred from the UPS model by looking at
        # /nix/store/nut/share/driver.list
        driver = lib.mkOption {
          description = ''
            Specify the program to run to talk to this UPS.  apcsmart,
            bestups, and sec are some examples.
          '';

          type = lib.types.str;
        };

        maxStartDelay = lib.mkOption {
          default = null;

          description = ''
            This can be set as a global variable above your first UPS
            definition and it can also be set in a UPS section.  This value
            controls how long upsdrvctl will wait for the driver to finish
            starting.  This keeps your system from getting stuck due to a
            broken driver or UPS.
          '';

          type = lib.types.uniq (lib.types.nullOr lib.types.int);
        };

        port = lib.mkOption {
          description = ''
            The serial port to which your UPS is connected.  /dev/ttyS0 is
            usually the first port on Linux boxes, for example.
          '';

          type = lib.types.str;
        };

        shutdownOrder = lib.mkOption {
          default = 0;

          description = ''
            When you have multiple UPSes on your system, you usually need to
            turn them off in a certain order.  upsdrvctl shuts down all the
            0s, then the 1s, 2s, and so on.  To exclude a UPS from the
            shutdown sequence, set this to -1.
          '';

          type = lib.types.int;
        };

        summary = lib.mkOption {
          default = "";

          description = ''
            Lines which would be added inside ups.conf for handling this UPS.
          '';

          type = lib.types.lines;
        };

      };

      config = {
        directives = lib.mkOrder 10 (
          [
            "driver = ${config.driver}"
            "port = ${config.port}"
            ''desc = "${config.description}"''
            "sdorder = ${toString config.shutdownOrder}"
          ]
          ++ (lib.optional (config.maxStartDelay != null) "maxstartdelay = ${toString config.maxStartDelay}")
        );

        summary = lib.concatStringsSep "\n      " ([ "[${name}]" ] ++ config.directives);
      };
    };

  listenOptions = {
    options = {
      address = lib.mkOption {
        description = ''
          Address of the interface for `upsd` to listen on.
          See `man upsd.conf` for details.
        '';

        type = lib.types.str;
      };

      port = lib.mkOption {
        default = defaultPort;

        description = ''
          TCP port for `upsd` to listen on.
          See `man upsd.conf` for details.
        '';

        type = lib.types.port;
      };
    };
  };

  upsdOptions = {
    options = {
      enable = lib.mkOption {
        defaultText = lib.literalMD "`true` if `mode` is one of `standalone`, `netserver`";
        description = "Whether to enable `upsd`.";
        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Additional lines to add to `upsd.conf`.
        '';

        type = lib.types.lines;
      };

      listen = lib.mkOption {
        default = [ ];

        description = ''
          Address of the interface for `upsd` to listen on.
          See `man upsd` for details`.
        '';

        example = [
          {
            address = "192.168.50.1";
          }
          {
            address = "::1";
            port = 5923;
          }
        ];

        type = with lib.types; listOf (submodule listenOptions);
      };
    };

    config = {
      enable = lib.mkDefault (
        lib.elem cfg.mode [
          "standalone"
          "netserver"
        ]
      );
    };
  };

  monitorOptions =
    { config, name, ... }:
    {
      options = {
        passwordFile = lib.mkOption {
          defaultText = lib.literalMD "power.ups.users.\${user}.passwordFile";

          description = ''
            The full path to a file containing the password from
            `upsd.users` for accessing this UPS. The password file
            is read on service start.
            See `upsmon.conf` for details.
          '';

          type = lib.types.str;
        };

        powerValue = lib.mkOption {
          default = 1;

          description = ''
            Number of power supplies that the UPS feeds on this system.
            See `upsmon.conf` for details.
          '';

          type = lib.types.int;
        };

        system = lib.mkOption {
          default = name;

          description = ''
            Identifier of the UPS to monitor, in this form: `<upsname>[@<hostname>[:<port>]]`
            See `upsmon.conf` for details.
          '';

          type = lib.types.str;
        };

        type = lib.mkOption {
          default = "master";

          description = ''
            The relationship with `upsd`.
            See `upsmon.conf` for details.
          '';

          type = lib.types.str;
        };

        user = lib.mkOption {
          description = ''
            Username from `upsd.users` for accessing this UPS.
            See `upsmon.conf` for details.
          '';

          type = lib.types.str;
        };
      };

      config = {
        passwordFile = lib.mkDefault cfg.users.${config.user}.passwordFile;
      };
    };

  upsmonOptions = {
    options = {
      enable = lib.mkOption {
        defaultText = lib.literalMD "`true` if `mode` is one of `standalone`, `netserver`, `netclient`";
        description = "Whether to enable `upsmon`.";
        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "nutmon";

        description = ''
          Group for the default `nutmon` user. If the default user is created
          and this is not specified, a default group will be created.
        '';

        type = lib.types.str;
      };

      monitor = lib.mkOption {
        default = { };

        description = ''
          Set of UPS to monitor. See `man upsmon.conf` for details.
        '';

        type = with lib.types; attrsOf (submodule monitorOptions);
      };

      settings = lib.mkOption {
        default = { };

        defaultText = lib.literalMD ''
          {
            MINSUPPLIES = 1;
            MONITOR = <generated from config.power.ups.upsmon.monitor>
            NOTIFYCMD = "''${cfg.package}/bin/upssched";
            POWERDOWNFLAG = "/run/killpower";
            SHUTDOWNCMD = "''${pkgs.systemd}/bin/shutdown now";
          }
        '';

        description = "Additional settings to add to `upsmon.conf`.";

        example = lib.literalMD ''
          {
            MINSUPPLIES = 2;
            NOTIFYFLAG = [
              [ "ONLINE" "SYSLOG+EXEC" ]
              [ "ONBATT" "SYSLOG+EXEC" ]
            ];
          }
        '';

        type = nutFormat.type;
      };

      user = lib.mkOption {
        default = "nutmon";

        description = ''
          User to run `upsmon` as. `upsmon.conf` will have its owner set to this
          user. If not specified, a default user will be created.
        '';

        type = lib.types.str;
      };
    };

    config = {
      enable = lib.mkDefault (
        lib.elem cfg.mode [
          "standalone"
          "netserver"
          "netclient"
        ]
      );

      settings = {
        MINSUPPLIES = lib.mkDefault 1;

        MONITOR = lib.flip lib.mapAttrsToList cfg.upsmon.monitor (
          name: monitor: with monitor; [
            system
            powerValue
            user
            "\"@upsmon_password_${name}@\""
            type
          ]
        );

        NOTIFYCMD = lib.mkDefault "${cfg.package}/bin/upssched";
        POWERDOWNFLAG = lib.mkDefault "/run/killpower";
        SHUTDOWNCMD = lib.mkDefault "${pkgs.systemd}/bin/shutdown now";
      };
    };
  };

  userOptions = {
    options = {
      actions = lib.mkOption {
        default = [ ];

        description = ''
          Allow the user to do certain things with upsd.
          See `man upsd.users` for details.
        '';

        type = with lib.types; listOf str;
      };

      instcmds = lib.mkOption {
        default = [ ];

        description = ''
          Let the user initiate specific instant commands. Use "ALL" to grant all commands automatically. For the full list of what your UPS supports, use "upscmd -l".
          See `man upsd.users` for details.
        '';

        type = with lib.types; listOf str;
      };

      passwordFile = lib.mkOption {
        description = ''
          The full path to a file that contains the user's (clear text)
          password. The password file is read on service start.
        '';

        type = lib.types.str;
      };

      upsmon = lib.mkOption {
        default = null;

        description = ''
          Add the necessary actions for a upsmon process to work.
          See `man upsd.users` for details.
        '';

        type =
          with lib.types;
          nullOr (enum [
            "primary"
            "secondary"
          ]);
      };
    };
  };

in

{
  options = {
    # powerManagement.powerDownCommands

    power.ups = {
      enable = lib.mkEnableOption ''
        support for Power Devices, such as Uninterruptible Power
        Supplies, Power Distribution Units and Solar Controllers
      '';

      package = lib.mkPackageOption pkgs "nut" { };

      maxStartDelay = lib.mkOption {
        default = 45;

        description = ''
          This can be set as a global variable above your first UPS
          definition and it can also be set in a UPS section.  This value
          controls how long upsdrvctl will wait for the driver to finish
          starting.  This keeps your system from getting stuck due to a
          broken driver or UPS.
        '';

        type = lib.types.int;
      };

      mode = lib.mkOption {
        default = "standalone";

        description = ''
          The MODE determines which part of the NUT is to be started, and
          which configuration files must be modified.

          The values of MODE can be:

          - none: NUT is not configured, or use the Integrated Power
            Management, or use some external system to startup NUT
            components. So nothing is to be started.

          - standalone: This mode address a local only configuration, with 1
            UPS protecting the local system. This implies to start the 3 NUT
            layers (driver, upsd and upsmon) and the matching configuration
            files. This mode can also address UPS redundancy.

          - netserver: same as for the standalone configuration, but also
            need some more ACLs and possibly a specific LISTEN directive in
            upsd.conf.  Since this MODE is opened to the network, a special
            care should be applied to security concerns.

          - netclient: this mode only requires upsmon.
        '';

        type = lib.types.enum [
          "none"
          "standalone"
          "netserver"
          "netclient"
        ];
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports in the firewall for `upsd`.
        '';

        type = lib.types.bool;
      };

      schedulerRules = lib.mkOption {
        description = ''
          File which contains the rules to handle UPS events.
        '';

        example = "/etc/nixos/upssched.conf";
        type = lib.types.str;
      };

      ups = lib.mkOption {
        default = { };

        # see nut/etc/ups.conf.sample
        description = ''
          This is where you configure all the UPSes that this system will be
          monitoring directly.  These are usually attached to serial ports,
          but USB devices are also supported.
        '';

        type = with lib.types; attrsOf (submodule upsOptions);
      };

      upsd = lib.mkOption {
        default = { };

        description = ''
          Options for the `upsd.conf` configuration file.
        '';

        type = lib.types.submodule upsdOptions;
      };

      upsmon = lib.mkOption {
        default = { };

        description = ''
          Options for the `upsmon.conf` configuration file.
        '';

        type = lib.types.submodule upsmonOptions;
      };

      users = lib.mkOption {
        default = { };

        description = ''
          Users that can access upsd. See `man upsd.users`.
        '';

        type = with lib.types; attrsOf (submodule userOptions);
      };

    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      (
        let
          totalPowerValue = lib.foldl' lib.add 0 (
            map (monitor: monitor.powerValue) (lib.attrValues cfg.upsmon.monitor)
          );
          minSupplies = cfg.upsmon.settings.MINSUPPLIES;
        in
        lib.mkIf cfg.upsmon.enable {
          assertion = totalPowerValue >= minSupplies;

          message = ''
            `power.ups.upsmon`: Total configured power value (${toString totalPowerValue}) must be at least MINSUPPLIES (${toString minSupplies}).
          '';
        }
      )
    ];

    environment.etc = {
      "nut/nut.conf".source = pkgs.writeText "nut.conf" ''
        MODE = ${cfg.mode}
      '';

      "nut/ups.conf".source = pkgs.writeText "ups.conf" ''
        maxstartdelay = ${toString cfg.maxStartDelay}

        ${lib.concatStringsSep "\n\n" (lib.forEach (lib.attrValues cfg.ups) (ups: ups.summary))}
      '';

      "nut/upsd.conf".source = pkgs.writeText "upsd.conf" ''
        ${lib.concatStringsSep "\n" (
          lib.forEach cfg.upsd.listen (listen: "LISTEN ${listen.address} ${toString listen.port}")
        )}
        ${cfg.upsd.extraConfig}
      '';

      "nut/upsd.users".source = "/run/nut/upsd.users";
      "nut/upsmon.conf".source = "/run/nut/upsmon.conf";
      "nut/upssched.conf".source = cfg.schedulerRules;
    };

    # For interactive use.
    environment.systemPackages = [ cfg.package ];
    environment.variables = envVars;

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts =
        if cfg.upsd.listen == [ ] then
          [ defaultPort ]
        else
          lib.unique (lib.forEach cfg.upsd.listen (listen: listen.port));
    };

    power.ups.schedulerRules = lib.mkDefault "${cfg.package}/etc/upssched.conf.sample";
    services.udev.packages = [ cfg.package ];

    systemd.services.ups-killpower = lib.mkIf (cfg.upsmon.settings.POWERDOWNFLAG != null) {
      enable = cfg.upsd.enable;
      after = [ "shutdown.target" ];
      before = [ "final.target" ];
      description = "UPS Kill Power";
      environment = envVars;

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/upsdrvctl shutdown";
        Type = "oneshot";
      };

      unitConfig = {
        ConditionPathExists = cfg.upsmon.settings.POWERDOWNFLAG;
        DefaultDependencies = "no";
      };

      wantedBy = [ "shutdown.target" ];
    };

    systemd.services.upsd =
      let
        secrets = lib.mapAttrsToList (name: user: "upsdusers_password_${name}") cfg.users;
        createUpsdUsers = installSecrets upsdUsers "/run/nut/upsd.users" "root" secrets;
      in
      {
        enable = cfg.upsd.enable;

        after = [
          "network.target"
          "upsmon.service"
        ];

        description = "Uninterruptible Power Supplies (Daemon)";
        environment = envVars;

        restartTriggers = [
          config.environment.etc."nut/upsd.conf".source
        ];

        serviceConfig = {
          ExecReload = "${cfg.package}/sbin/upsd -c reload";
          # TODO: replace 'root' by another username.
          ExecStart = "${cfg.package}/sbin/upsd -u root";
          ExecStartPre = "${createUpsdUsers}";

          LoadCredential = lib.mapAttrsToList (
            name: user: "upsdusers_password_${name}:${user.passwordFile}"
          ) cfg.users;

          Slice = "system-ups.slice";
          Type = "forking";
        };

        wantedBy = [ "multi-user.target" ];
      };

    systemd.services.upsdrv = {
      enable = cfg.upsd.enable;
      after = [ "upsd.service" ];
      description = "Uninterruptible Power Supplies (Register all UPS)";
      environment = envVars;

      restartTriggers = [
        config.environment.etc."nut/ups.conf".source
      ];

      serviceConfig = {
        # TODO: replace 'root' by another username.
        ExecStart = "${cfg.package}/bin/upsdrvctl -u root start";
        RemainAfterExit = true;
        Slice = "system-ups.slice";
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.upsmon =
      let
        secrets = lib.mapAttrsToList (name: monitor: "upsmon_password_${name}") cfg.upsmon.monitor;
        createUpsmonConf = installSecrets upsmonConf "/run/nut/upsmon.conf" cfg.upsmon.user secrets;
      in
      {
        enable = cfg.upsmon.enable;
        after = [ "network.target" ];
        description = "Uninterruptible Power Supplies (Monitor)";
        environment = envVars;

        serviceConfig = {
          ExecReload = "${cfg.package}/sbin/upsmon -c reload";
          ExecStart = "${cfg.package}/sbin/upsmon -u ${cfg.upsmon.user}";
          ExecStartPre = "${createUpsmonConf}";

          LoadCredential = lib.mapAttrsToList (
            name: monitor: "upsmon_password_${name}:${monitor.passwordFile}"
          ) cfg.upsmon.monitor;

          Slice = "system-ups.slice";
          Type = "forking";
        };

        wantedBy = [ "multi-user.target" ];
      };

    systemd.slices.system-ups = {
      description = "Network UPS Tools (NUT) Slice";
      documentation = [ "https://networkupstools.org/" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/state/ups -"
      "d /var/lib/nut 700"
    ];

    users.groups.nutmon = lib.mkIf (cfg.upsmon.user == "nutmon" && cfg.upsmon.group == "nutmon") { };

    users.users.nutmon = lib.mkIf (cfg.upsmon.user == "nutmon") {
      group = cfg.upsmon.group;
      isSystemUser = true;
    };

  };
}
