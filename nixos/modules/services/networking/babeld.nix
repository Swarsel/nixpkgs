{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.babeld;

  conditionalBoolToString =
    value: if (lib.isBool value) then (lib.boolToString value) else (toString value);

  paramsString =
    params:
    lib.concatMapStringsSep " " (name: "${name} ${conditionalBoolToString (lib.getAttr name params)}") (
      lib.attrNames params
    );

  interfaceConfig =
    name:
    let
      interface = lib.getAttr name cfg.interfaces;
    in
    "interface ${name} ${paramsString interface}\n";

  configFile =
    with cfg;
    pkgs.writeText "babeld.conf" (
      ''
        skip-kernel-setup true
      ''
      + (lib.optionalString (cfg.interfaceDefaults != null) ''
        default ${paramsString cfg.interfaceDefaults}
      '')
      + (lib.concatMapStrings interfaceConfig (lib.attrNames cfg.interfaces))
      + extraConfig
    );

in

{

  ###### interface

  options = {

    services.babeld = {

      enable = lib.mkEnableOption "the babeld network routing daemon";

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Options that will be copied to babeld.conf.
          See {manpage}`babeld(8)` for details.
        '';

        type = lib.types.lines;
      };

      interfaceDefaults = lib.mkOption {
        default = null;

        description = ''
          A set describing default parameters for babeld interfaces.
          See {manpage}`babeld(8)` for options.
        '';

        example = {
          split-horizon = true;
          type = "tunnel";
        };

        type = lib.types.nullOr (lib.types.attrsOf lib.types.unspecified);
      };

      interfaces = lib.mkOption {
        default = { };

        description = ''
          A set describing babeld interfaces.
          See {manpage}`babeld(8)` for options.
        '';

        example = {
          enp0s2 = {
            hello-interval = 5;
            split-horizon = "auto";
            type = "wired";
          };
        };

        type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
      };
    };

  };

  ###### implementation

  config = lib.mkIf config.services.babeld.enable {

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.rp_filter" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.all.forwarding" = 1;
    }
    // lib.mapAttrs' (
      ifname: _: lib.nameValuePair "net.ipv4.conf.${ifname}.rp_filter" (lib.mkDefault 0)
    ) config.services.babeld.interfaces;

    systemd.services.babeld = {
      after = [ "network.target" ];
      description = "Babel routing daemon";

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_ADMIN" ];
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${pkgs.babeld}/bin/babeld -c ${configFile} -I /run/babeld/babeld.pid -S /var/lib/babeld/state";

        IPAddressAllow = [
          "fe80::/64"
          "ff00::/8"
          "::1/128"
          "127.0.0.0/8"
        ];

        IPAddressDeny = "any";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = false; # kernel_route(ADD): Operation not permitted
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
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_NETLINK"
          "AF_INET6"
          "AF_INET"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "babeld";
        StateDirectory = "babeld";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged @resources"
        ];

        UMask = "0177";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
