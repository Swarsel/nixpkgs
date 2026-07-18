{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.connman;
  configFile = pkgs.writeText "connman.conf" ''
    [General]
    NetworkInterfaceBlacklist=${lib.concatStringsSep "," cfg.networkInterfaceBlacklist}

    ${cfg.extraConfig}
  '';
  enableIwd = cfg.wifi.backend == "iwd";
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "networking" "connman" ] [ "services" "connman" ])
  ];

  ###### interface
  options = {
    services.connman = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to use ConnMan for managing your network connections.
        '';

        type = lib.types.bool;
      };

      package = lib.mkOption {
        default = pkgs.connman;
        defaultText = lib.literalExpression "pkgs.connman";
        description = "The connman package / build flavor";
        example = lib.literalExpression "pkgs.connmanFull";
        type = lib.types.package;
      };

      enableVPN = lib.mkOption {
        default = true;

        description = ''
          Whether to enable ConnMan VPN service.
        '';

        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Configuration lines appended to the generated connman configuration file.
        '';

        type = lib.types.lines;
      };

      extraFlags = lib.mkOption {
        default = [ ];

        description = ''
          Extra flags to pass to connmand
        '';

        example = [ "--nodnsproxy" ];
        type = lib.types.listOf lib.types.str;
      };

      networkInterfaceBlacklist = lib.mkOption {
        default = [
          "vmnet"
          "vboxnet"
          "virbr"
          "ifb"
          "ve"
        ];

        description = ''
          Default blacklisted interfaces, this includes NixOS containers interfaces (ve).
        '';

        type = lib.types.listOf lib.types.str;
      };

      wifi = {
        backend = lib.mkOption {
          default = "wpa_supplicant";

          description = ''
            Specify the Wi-Fi backend used.
            Currently supported are {option}`wpa_supplicant` or {option}`iwd`.
          '';

          type = lib.types.enum [
            "wpa_supplicant"
            "iwd"
          ];
        };
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.networking.useDHCP;
        message = "You can not use services.connman with networking.useDHCP";
      }
      {
        # TODO: connman seemingly can be used along network manager and
        # connmanFull supports this - so this should be worked out somehow
        assertion = !config.networking.networkmanager.enable;
        message = "You can not use services.connman with networking.networkmanager";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    networking = {
      networkmanager.enable = false;
      useDHCP = false;

      wireless = {
        enable = lib.mkIf (!enableIwd) true;
        autoDetectInterfaces = false;
        dbusControlled = true;

        iwd = lib.mkIf enableIwd {
          enable = true;
        };
      };
    };

    systemd.services.connman = {
      after = lib.optional enableIwd "iwd.service";
      description = "Connection service";
      requires = lib.optional enableIwd "iwd.service";

      serviceConfig = {
        BusName = "net.connman";

        ExecStart = toString (
          [
            "${cfg.package}/sbin/connmand"
            "--config=${configFile}"
            "--nodaemon"
          ]
          ++ lib.optional enableIwd "--wifi=iwd_agent"
          ++ cfg.extraFlags
        );

        Restart = "on-failure";
        StandardOutput = "null";
        Type = "dbus";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.connman-vpn = lib.mkIf cfg.enableVPN {
      before = [ "connman.service" ];
      description = "ConnMan VPN service";

      serviceConfig = {
        BusName = "net.connman.vpn";
        ExecStart = "${cfg.package}/sbin/connman-vpnd -n";
        StandardOutput = "null";
        Type = "dbus";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.net-connman-vpn = lib.mkIf cfg.enableVPN {
      description = "D-BUS Service";

      serviceConfig = {
        ExecStart = "${cfg.package}/sbin/connman-vpnd -n";
        Name = "net.connman.vpn";
        SystemdService = "connman-vpn.service";
        User = "root";
        before = [ "connman.service" ];
      };
    };
  };

  meta.maintainers = [ ];
}
