{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.services.frr;

  daemons = [
    "bgpd"
    "ospfd"
    "ospf6d"
    "ripd"
    "ripngd"
    "isisd"
    "pimd"
    "pim6d"
    "ldpd"
    "nhrpd"
    "eigrpd"
    "babeld"
    "sharpd"
    "pbrd"
    "bfdd"
    "fabricd"
    "vrrpd"
    "pathd"
  ];

  daemonDefaultOptions = {
    babeld = "-A 127.0.0.1";
    bfdd = "-A 127.0.0.1";
    bgpd = "-A 127.0.0.1";
    eigrpd = "-A 127.0.0.1";
    fabricd = "-A 127.0.0.1";
    isisd = "-A 127.0.0.1";
    ldpd = "-A 127.0.0.1";
    mgmtd = "-A 127.0.0.1";
    nhrpd = "-A 127.0.0.1";
    ospf6d = "-A ::1";
    ospfd = "-A 127.0.0.1";
    pathd = "-A 127.0.0.1";
    pbrd = "-A 127.0.0.1";
    pim6d = "-A ::1";
    pimd = "-A 127.0.0.1";
    ripd = "-A 127.0.0.1";
    ripngd = "-A ::1";
    sharpd = "-A 127.0.0.1";
    staticd = "-A 127.0.0.1";
    vrrpd = "-A 127.0.0.1";
    zebra = "-A 127.0.0.1 -s 90000000";
  };

  renamedServices = [
    "bgp"
    "ospf"
    "ospf6"
    "rip"
    "ripng"
    "isis"
    "pim"
    "ldp"
    "nhrp"
    "eigrp"
    "babel"
    "sharp"
    "pbr"
    "bfd"
    "fabric"
  ];

  obsoleteServices = renamedServices ++ [
    "static"
    "mgmt"
    "zebra"
  ];

  allDaemons = builtins.attrNames daemonDefaultOptions;

  isEnabled = service: cfg.${service}.enable;

  daemonLine = d: "${d}=${lib.boolToYesNo (isEnabled d)}";

  configFile =
    if cfg.configFile != null then
      cfg.configFile
    else
      pkgs.writeText "frr.conf" ''
        ! FRR configuration
        !
        hostname ${config.networking.hostName}
        log syslog
        service password-encryption
        service integrated-vtysh-config
        !
        ${cfg.config}
        !
        end
      '';

  serviceOptions =
    service:
    {
      options = lib.mkOption {
        default = [ daemonDefaultOptions.${service} ];

        description = ''
          Options for the FRR ${service} daemon.
        '';

        type = lib.types.listOf lib.types.str;
      };

      extraOptions = lib.mkOption {
        default = [ ];

        description = ''
          Extra options to be appended to the FRR ${service} daemon options.
        '';

        type = lib.types.listOf lib.types.str;
      };
    }
    // (
      if (builtins.elem service daemons) then { enable = lib.mkEnableOption "FRR ${service}"; } else { }
    );

in

{

  ###### interface
  imports = [
    {
      options.services.frr = {
        config = lib.mkOption {
          default = "";

          description = ''
            FRR configuration statements.
          '';

          example = ''
            router rip
              network 10.0.0.0/8
            router ospf
              network 10.0.0.0/8 area 0
            router bgp 65001
              neighbor 10.0.0.1 remote-as 65001
          '';

          type = lib.types.lines;
        };

        configFile = lib.mkOption {
          default = null;

          description = ''
            Configuration file to use for FRR.
            By default the NixOS generated files are used.
          '';

          example = "/etc/frr/frr.conf";
          type = lib.types.nullOr lib.types.path;
        };

        openFilesLimit = lib.mkOption {
          default = 1024;

          description = ''
            This is the maximum number of FD's that will be available.  Use a
            reasonable value for your setup if you are expecting a large number
            of peers in say BGP.
          '';

          type = lib.types.ints.unsigned;
        };
      };
    }
    { options.services.frr = (lib.genAttrs allDaemons serviceOptions); }
    (lib.mkRemovedOptionModule [ "services" "frr" "zebra" "enable" ] "FRR zebra is always enabled")
  ]
  ++ (map (
    d: lib.mkRenamedOptionModule [ "services" "frr" d "enable" ] [ "services" "frr" "${d}d" "enable" ]
  ) renamedServices)
  ++ (map
    (
      d:
      lib.mkRenamedOptionModule
        [ "services" "frr" d "extraOptions" ]
        [ "services" "frr" "${d}d" "extraOptions" ]
    )
    (
      renamedServices
      ++ [
        "static"
        "mgmt"
      ]
    )
  )
  ++ (map (d: lib.mkRemovedOptionModule [ "services" "frr" d "enable" ] "FRR ${d}d is always enabled")
    [
      "static"
      "mgmt"
    ]
  )
  ++ (map (
    d:
    lib.mkRemovedOptionModule [
      "services"
      "frr"
      d
      "config"
    ] "FRR switched to integrated-vtysh-config, please use services.frr.config"
  ) obsoleteServices)
  ++ (map (
    d:
    lib.mkRemovedOptionModule [ "services" "frr" d "configFile" ]
      "FRR switched to integrated-vtysh-config, please use services.frr.config or services.frr.configFile"
  ) obsoleteServices)
  ++ (map (
    d:
    lib.mkRemovedOptionModule [
      "services"
      "frr"
      d
      "vtyListenAddress"
    ] "Please change -A option in services.frr.${d}.options instead"
  ) obsoleteServices)
  ++ (map (
    d:
    lib.mkRemovedOptionModule [ "services" "frr" d "vtyListenPort" ]
      "Please use `-P «vtyListenPort»` option with services.frr.${d}.extraOptions instead, or change services.frr.${d}.options accordingly"
  ) obsoleteServices);

  ###### implementation

  config =
    let
      daemonList = lib.concatStringsSep "\n" (map daemonLine daemons);
      daemonOptionLine =
        d: "${d}_options=\"${lib.concatStringsSep " " (cfg.${d}.options ++ cfg.${d}.extraOptions)}\"";
      daemonOptions = lib.concatStringsSep "\n" (map daemonOptionLine allDaemons);
    in
    lib.mkIf (lib.any isEnabled daemons || cfg.configFile != null || cfg.config != "") {

      environment.etc = {
        "frr/daemons".text = ''
          # This file tells the frr package which daemons to start.
          #
          # The watchfrr, zebra and staticd daemons are always started.
          #
          # This part is auto-generated from services.frr.<daemon>.enable config
          ${daemonList}

          # If this option is set the /etc/init.d/frr script automatically loads
          # the config via "vtysh -b" when the servers are started.
          #
          vtysh_enable=yes

          # This part is auto-generated from services.frr.<daemon>.options or
          # services.frr.<daemon>.extraOptions
          ${daemonOptions}
        '';

        "frr/frr.conf".source = configFile;

        "frr/vtysh.conf".text = ''
          service integrated-vtysh-config
        '';
      };

      environment.systemPackages = [
        pkgs.frr # for the vtysh tool
      ];

      systemd.services.frr = {
        after = [
          "network-pre.target"
          "systemd-sysctl.service"
        ];

        before = [ "network.target" ];
        description = "FRRouting";
        documentation = [ "https://frrouting.readthedocs.io/en/latest/setup.html" ];
        reloadIfChanged = true;

        restartTriggers = [
          configFile
          daemonList
        ];

        serviceConfig = {
          ExecReload = "${pkgs.frr}/libexec/frr/frrinit.sh reload";
          ExecStart = "${pkgs.frr}/libexec/frr/frrinit.sh start";
          ExecStop = "${pkgs.frr}/libexec/frr/frrinit.sh stop";
          LimitNOFILE = cfg.openFilesLimit;
          Nice = -5;
          NotifyAccess = "all";
          PIDFile = "/run/frr/watchfrr.pid";
          Restart = "always";
          RestartSec = 5;
          TimeoutSec = 120;
          Type = "forking";
          WatchdogSec = 60;
        };

        startLimitIntervalSec = 180;

        unitConfig = {
          StartLimitBurst = "3";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network.target" ];
      };

      systemd.tmpfiles.rules = [ "d /run/frr 0755 frr frr -" ];

      users.groups = {
        frr = { };

        # Members of the frrvty group can use vtysh to inspect the FRR daemons
        frrvty = {
          members = [ "frr" ];
        };
      };

      users.users.frr = {
        description = "FRR daemon user";
        group = "frr";
        isSystemUser = true;
      };
    };

  meta.maintainers = with lib.maintainers; [ woffs ];
}
