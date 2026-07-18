{
  config,
  lib,
  pkgs,
  ...
}:
let

  pkg = config.hardware.sane.backends-package.override {
    scanSnapDriversPackage = config.hardware.sane.drivers.scanSnap.package;
    scanSnapDriversUnfree = config.hardware.sane.drivers.scanSnap.enable;
  };

  sanedConf = pkgs.writeTextFile {
    destination = "/etc/sane.d/saned.conf";
    name = "saned.conf";

    text = ''
      localhost
      ${config.services.saned.extraConfig}
    '';
  };

  netConf = pkgs.writeTextFile {
    destination = "/etc/sane.d/net.conf";
    name = "net.conf";

    text = ''
      ${lib.optionalString config.services.saned.enable "localhost"}
      ${config.hardware.sane.netConf}
    '';
  };

  env = {
    LD_LIBRARY_PATH = [ "/etc/sane-libs" ];
    SANE_CONFIG_DIR = "/etc/sane-config";
  };

  backends = [
    pkg
    netConf
  ]
  ++ lib.optional config.services.saned.enable sanedConf
  ++ config.hardware.sane.extraBackends;
  saneConfig = pkgs.mkSaneConfig {
    inherit (config.hardware.sane) disabledDefaultBackends;
    paths = backends;
  };

  enabled = config.hardware.sane.enable || config.services.saned.enable;

in

{

  ###### interface

  options = {

    hardware.sane.backends-package = lib.mkPackageOption pkgs "sane-backends" { };

    hardware.sane.configDir = lib.mkOption {
      description = "The value of SANE_CONFIG_DIR.";
      internal = true;
      type = lib.types.str;
    };

    hardware.sane.disabledDefaultBackends = lib.mkOption {
      default = [ ];

      description = ''
        Names of backends which are enabled by default but should be disabled.
        See `$SANE_CONFIG_DIR/dll.conf` for the list of possible names.
      '';

      example = [ "v4l" ];
      type = lib.types.listOf lib.types.str;
    };

    hardware.sane.drivers.scanSnap.enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable drivers for the Fujitsu ScanSnap scanners.

        The driver files are unfree and extracted from the Windows driver image.
      '';

      example = true;
      type = lib.types.bool;
    };

    hardware.sane.drivers.scanSnap.package = lib.mkPackageOption pkgs [ "sane-drivers" "epjitsu" ] {
      extraDescription = ''
        Useful if you want to extract the driver files yourself.

        The process is described in the {file}`/etc/sane.d/epjitsu.conf` file in
        the `sane-backends` package.
      '';
    };

    hardware.sane.enable = lib.mkOption {
      default = false;

      description = ''
        Enable support for SANE scanners.

        ::: {.note}
        Users in the "scanner" group will gain access to the scanner, or the "lp" group if it's also a printer.
        :::
      '';

      type = lib.types.bool;
    };

    hardware.sane.extraBackends = lib.mkOption {
      default = [ ];

      description = ''
        Packages providing extra SANE backends to enable.

        ::: {.note}
        The example contains the package for HP scanners, and the package for
        Apple AirScan and Microsoft WSD support (supports many
        vendors/devices).
        :::
      '';

      example = lib.literalExpression "[ pkgs.hplipWithPlugin pkgs.sane-airscan ]";
      type = lib.types.listOf lib.types.path;
    };

    hardware.sane.netConf = lib.mkOption {
      default = "";

      description = ''
        Network hosts that should be probed for remote scanners.
      '';

      example = "192.168.0.16";
      type = lib.types.lines;
    };

    hardware.sane.openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open ports needed for discovery of scanners on the local network, e.g.
        needed for Canon scanners (BJNP protocol).
      '';

      type = lib.types.bool;
    };

    hardware.sane.snapshot = lib.mkOption {
      default = false;
      description = "Use a development snapshot of SANE scanner drivers.";
      type = lib.types.bool;
    };

    services.saned.enable = lib.mkOption {
      default = false;

      description = ''
        Enable saned network daemon for remote connection to scanners.

        saned would be run from `scanner` user; to allow
        access to hardware that doesn't have `scanner` group
        you should add needed groups to this user.
      '';

      type = lib.types.bool;
    };

    services.saned.extraConfig = lib.mkOption {
      default = "";

      description = ''
        Extra saned configuration lines.
      '';

      example = "192.168.0.0/24";
      type = lib.types.lines;
    };

  };

  ###### implementation

  config = lib.mkMerge [
    (lib.mkIf enabled {
      environment.etc."sane-config".source = config.hardware.sane.configDir;
      environment.etc."sane-libs".source = "${saneConfig}/lib/sane";
      environment.sessionVariables = env;
      environment.systemPackages = backends;
      hardware.sane.configDir = lib.mkDefault "${saneConfig}/etc/sane.d";
      networking.firewall.allowedUDPPorts = lib.mkIf config.hardware.sane.openFirewall [ 8612 ];

      # sane sets up udev rules that tag scanners with `uaccess`. This way, physically logged in users
      # can access them without belonging to the `scanner` group. However, the `scanner` user used by saned
      # does not have a real logind seat, so `uaccess` is not enough.
      services.udev.extraRules = ''
        ENV{DEVNAME}!="", ENV{libsane_matched}=="yes", RUN+="${pkgs.acl}/bin/setfacl -m g:scanner:rw $env{DEVNAME}"
      '';

      services.udev.packages = backends;

      systemd.tmpfiles.rules = [
        "d /var/lock/sane 0770 root scanner - -"
      ];

      users.groups.scanner.gid = config.ids.gids.scanner;
    })

    (lib.mkIf config.services.saned.enable {
      networking.firewall.connectionTrackingModules = [ "sane" ];

      systemd.services."saned@" = {
        description = "Scanner Service";
        environment = lib.mapAttrs (name: val: toString val) env;

        serviceConfig = {
          ExecStart = "${pkg}/bin/saned";
          Group = "scanner";
          User = "scanner";
        };
      };

      systemd.sockets.saned = {
        description = "saned incoming socket";

        listenStreams = [
          "0.0.0.0:6566"
          "[::]:6566"
        ];

        socketConfig = {
          Accept = true;
          # saned needs to distinguish between IPv4 and IPv6 to open matching data sockets.
          BindIPv6Only = "ipv6-only";
          MaxConnections = 64;
        };

        wantedBy = [ "sockets.target" ];
      };

      users.users.scanner = {
        extraGroups = [ "lp" ] ++ lib.optionals config.services.avahi.enable [ "avahi" ];
        group = "scanner";
        uid = config.ids.uids.scanner;
      };
    })
  ];

}
