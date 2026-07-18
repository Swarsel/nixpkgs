{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let

  cfg = config.networking.wireguard;
  opt = options.networking.wireguard;

  kernel = config.boot.kernelPackages;

  # interface options

  interfaceOpts =
    { ... }:
    {

      options = {

        allowedIPsAsRoutes = mkOption {
          default = true;

          description = ''
            Determines whether to add allowed IPs as routes or not.
          '';

          example = false;
          type = types.bool;
        };

        dynamicEndpointRefreshSeconds = mkOption {
          default = 0;

          description = ''
            Periodically refresh the endpoint hostname or address for all peers.
            Allows WireGuard to notice DNS and IPv4/IPv6 connectivity changes.
            This option can be set or overridden for individual peers.

            Setting this to `0` disables periodic refresh.
          '';

          example = 300;
          type = with types; int;
        };

        extraOptions = mkOption {
          default = { };

          description = ''
            Extra options to append to the interface section. Can be used to define AmneziaWG-specific options.
          '';

          example = {
            H4 = 12345;
            Jc = 5;
            Jmax = 42;
            Jmin = 10;
            S1 = 60;
            S2 = 90;
          };

          type =
            with types;
            attrsOf (oneOf [
              str
              int
            ]);
        };

        fwMark = mkOption {
          default = null;

          description = ''
            Mark all wireguard packets originating from
            this interface with the given firewall mark. The firewall mark can be
            used in firewalls or policy routing to filter the wireguard packets.
            This can be useful for setup where all traffic goes through the
            wireguard tunnel, because the wireguard packets need to be routed
            differently.
          '';

          example = "0x6e6978";
          type = with types; nullOr str;
        };

        generatePrivateKeyFile = mkOption {
          default = false;

          description = ''
            Automatically generate a private key with
            {command}`wg genkey`, at the privateKeyFile location.
          '';

          type = types.bool;
        };

        interfaceNamespace = mkOption {
          default = null;

          description = ''
            The pre-existing network namespace the WireGuard
            interface is moved to. The special value `init` means
            the init namespace. When `null`, the interface is not
            moved.
            See [documentation](https://www.wireguard.com/netns/).
          '';

          example = "init";
          type = with types; nullOr str;
        };

        ips = mkOption {
          default = [ ];
          description = "The IP addresses of the interface.";
          example = [ "192.168.2.1/24" ];
          type = with types; listOf str;
        };

        listenPort = mkOption {
          default = null;

          description = ''
            16-bit port for listening. Optional; if not specified,
            automatically generated based on interface name.
          '';

          example = 51820;
          type = with types; nullOr int;
        };

        metric = mkOption {
          default = null;

          description = ''
            Set the metric of routes related to this Wireguard interface.
          '';

          example = 700;
          type = with types; nullOr int;
        };

        mtu = mkOption {
          default = null;

          description = ''
            Set the maximum transmission unit in bytes for the wireguard
            interface. Beware that the wireguard packets have a header that may
            add up to 80 bytes to the mtu. By default, the MTU is (1500 - 80) =
            1420. However, if the MTU of the upstream network is lower, the MTU
            of the wireguard network has to be adjusted as well.
          '';

          example = 1280;
          type = with types; nullOr int;
        };

        peers = mkOption {
          default = [ ];
          description = "Peers linked to the interface.";
          type = with types; listOf (submodule peerOpts);
        };

        postSetup = mkOption {
          default = "";
          description = "Commands called at the end of the interface setup.";

          example = literalExpression ''
            '''printf "nameserver 10.200.100.1" | ''${pkgs.openresolv}/bin/resolvconf -a wg0 -m 0'''
          '';

          type = with types; coercedTo (listOf str) (concatStringsSep "\n") lines;
        };

        postShutdown = mkOption {
          default = "";
          description = "Commands called after shutting down the interface.";
          example = literalExpression ''"''${pkgs.openresolv}/bin/resolvconf -d wg0"'';
          type = with types; coercedTo (listOf str) (concatStringsSep "\n") lines;
        };

        preSetup = mkOption {
          default = "";

          description = ''
            Commands called at the start of the interface setup.
          '';

          example = literalExpression ''"''${pkgs.iproute2}/bin/ip netns add foo"'';
          type = with types; coercedTo (listOf str) (concatStringsSep "\n") lines;
        };

        preShutdown = mkOption {
          default = "";

          description = ''
            Commands called before shutting down the interface.
          '';

          example = literalExpression ''"''${pkgs.iproute2}/bin/ip netns del foo"'';
          type = with types; coercedTo (listOf str) (concatStringsSep "\n") lines;
        };

        privateKey = mkOption {
          default = null;

          description = ''
            Base64 private key generated by {command}`wg genkey`.

            Warning: Consider using privateKeyFile instead if you do not
            want to store the key in the world-readable Nix store.
          '';

          example = "yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=";
          type = with types; nullOr str;
        };

        privateKeyFile = mkOption {
          default = null;

          description = ''
            Private key file as generated by {command}`wg genkey`.
          '';

          example = "/private/wireguard_key";
          type = with types; nullOr str;
        };

        socketNamespace = mkOption {
          default = null;

          description = ''
            The pre-existing network namespace in which the
            WireGuard interface is created, and which retains the socket even if the
            interface is moved via {option}`interfaceNamespace`. When
            `null`, the interface is created in the init namespace.
            See [documentation](https://www.wireguard.com/netns/).
          '';

          example = "container";
          type = with types; nullOr str;
        };

        table = mkOption {
          default = "main";

          description = ''
            The kernel routing table to add this interface's
            associated routes to. Setting this is useful for e.g. policy routing
            ("ip rule") or virtual routing and forwarding ("ip vrf"). Both
            numeric table IDs and table names (/etc/rt_tables) can be used.
            Defaults to "main".
          '';

          type = types.str;
        };

        type = mkOption {
          default = "wireguard";

          description = ''
            The type of the interface. Currently only "wireguard" and "amneziawg" are supported.
          '';

          example = "amneziawg";

          type = types.enum [
            "wireguard"
            "amneziawg"
          ];
        };
      };

    };

  # peer options

  peerOpts = self: {

    options = {

      allowedIPs = mkOption {
        description = ''
          List of IP (v4 or v6) addresses with CIDR masks from
          which this peer is allowed to send incoming traffic and to which
          outgoing traffic for this peer is directed. The catch-all 0.0.0.0/0 may
          be specified for matching all IPv4 addresses, and ::/0 may be specified
          for matching all IPv6 addresses.'';

        example = [
          "10.192.122.3/32"
          "10.192.124.1/24"
        ];

        type = with types; listOf str;
      };

      dynamicEndpointRefreshRestartSeconds = mkOption {
        default = null;

        description = ''
          When the dynamic endpoint refresh that is configured via
          dynamicEndpointRefreshSeconds exits (likely due to a failure),
          restart that service after this many seconds.

          If set to `null` the value of
          {option}`networking.wireguard.dynamicEndpointRefreshSeconds`
          will be used as the default.
        '';

        example = 5;
        type = with types; nullOr ints.unsigned;
      };

      dynamicEndpointRefreshSeconds = mkOption {
        default = null;
        defaultText = literalExpression "config.networking.wireguard.interfaces.<name>.dynamicEndpointRefreshSeconds";

        description = ''
          Periodically re-execute the `wg` utility every
          this many seconds in order to let WireGuard notice DNS / hostname
          changes.

          Setting this to `0` disables periodic reexecution.

          ::: {.note}
          This peer-level setting is not available when {option}`networking.wireguard.useNetworkd`
          is enabled. The interface-level setting may be used instead.
          :::
        '';

        example = 5;
        type = with types; nullOr int;
      };

      endpoint = mkOption {
        default = null;

        description = ''
          Endpoint IP or hostname of the peer, followed by a colon,
          and then a port number of the peer.

          Warning for endpoints with changing IPs:
          The WireGuard kernel side cannot perform DNS resolution.
          Thus DNS resolution is done once by the `wg` userspace
          utility, when setting up WireGuard. Consequently, if the IP address
          behind the name changes, WireGuard will not notice.
          This is especially common for dynamic-DNS setups, but also applies to
          any other DNS-based setup.
          If you do not use IP endpoints, you likely want to set
          {option}`networking.wireguard.dynamicEndpointRefreshSeconds`
          to refresh the IPs periodically.
        '';

        example = "demo.wireguard.io:12913";
        type = with types; nullOr str;
      };

      name = mkOption {
        default =
          replaceStrings [ "/" "-" " " "+" "=" ] [ "-" "\\x2d" "\\x20" "\\x2b" "\\x3d" ]
            self.config.publicKey;

        defaultText = literalExpression "publicKey";
        description = "Name used to derive peer unit name.";
        example = "bernd";
        type = types.str;
      };

      persistentKeepalive = mkOption {
        default = null;

        description = ''
          This is optional and is by default off, because most
          users will not need it. It represents, in seconds, between 1 and 65535
          inclusive, how often to send an authenticated empty packet to the peer,
          for the purpose of keeping a stateful firewall or NAT mapping valid
          persistently. For example, if the interface very rarely sends traffic,
          but it might at anytime receive traffic from a peer, and it is behind
          NAT, the interface might benefit from having a persistent keepalive
          interval of 25 seconds; however, most users will not need this.'';

        example = 25;
        type = with types; nullOr int;
      };

      presharedKey = mkOption {
        default = null;

        description = ''
          Base64 preshared key generated by {command}`wg genpsk`.
          Optional, and may be omitted. This option adds an additional layer of
          symmetric-key cryptography to be mixed into the already existing
          public-key cryptography, for post-quantum resistance.

          Warning: Consider using presharedKeyFile instead if you do not
          want to store the key in the world-readable Nix store.
        '';

        example = "rVXs/Ni9tu3oDBLS4hOyAUAa1qTWVA3loR8eL20os3I=";
        type = with types; nullOr str;
      };

      presharedKeyFile = mkOption {
        default = null;

        description = ''
          File pointing to preshared key as generated by {command}`wg genpsk`.
          Optional, and may be omitted. This option adds an additional layer of
          symmetric-key cryptography to be mixed into the already existing
          public-key cryptography, for post-quantum resistance.
        '';

        example = "/private/wireguard_psk";
        type = with types; nullOr str;
      };

      publicKey = mkOption {
        description = "The base64 public key of the peer.";
        example = "xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=";
        type = types.singleLineStr;
      };

    };

  };

  wgBins = {
    amneziawg = "awg";
    wireguard = "wg";
  };

  wgPackages = {
    amneziawg = pkgs.amneziawg-tools;
    wireguard = pkgs.wireguard-tools;
  };

  generateKeyServiceUnit =
    name: values:
    assert values.generatePrivateKeyFile;
    nameValuePair "wireguard-${name}-key" {
      before = [ "wireguard-${name}.service" ];
      description = "WireGuard Tunnel - ${name} - Key Generator";
      path = [ wgPackages.${values.type} ];
      requiredBy = [ "wireguard-${name}.service" ];

      script = ''
        set -e

        # If the parent dir does not already exist, create it.
        # Otherwise, does nothing, keeping existing permissions intact.
        mkdir -p --mode 0755 "${dirOf values.privateKeyFile}"

        if [ ! -f "${values.privateKeyFile}" ]; then
          # Write private key file with atomically-correct permissions.
          (set -e; umask 077; ${wgBins.${values.type}} genkey > "${values.privateKeyFile}")
        fi
      '';

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "wireguard-${name}.service" ];
    };

  peerUnitServiceName =
    interfaceName: peerName: dynamicRefreshEnabled:
    let
      refreshSuffix = optionalString dynamicRefreshEnabled "-refresh";
    in
    "wireguard-${interfaceName}-peer-${peerName}${refreshSuffix}";

  dynamicRefreshSeconds =
    interfaceCfg: peer:
    if peer.dynamicEndpointRefreshSeconds != null then
      peer.dynamicEndpointRefreshSeconds
    else
      interfaceCfg.dynamicEndpointRefreshSeconds;

  generatePeerUnit =
    {
      interfaceCfg,
      interfaceName,
      peer,
    }:
    let
      psk =
        if peer.presharedKey != null then
          pkgs.writeText "wg-psk" peer.presharedKey
        else
          peer.presharedKeyFile;
      src = interfaceCfg.socketNamespace;
      dst = interfaceCfg.interfaceNamespace;
      ip = nsWrap "ip" src dst;
      wg = nsWrap wgBins.${interfaceCfg.type} src dst;
      dynamicEndpointRefreshSeconds = dynamicRefreshSeconds interfaceCfg peer;
      dynamicRefreshEnabled = dynamicEndpointRefreshSeconds != 0;
      # We generate a different name (a `-refresh` suffix) when `dynamicEndpointRefreshSeconds`
      # to avoid that the same service switches `Type` (`oneshot` vs `simple`),
      # with the intent to make scripting more obvious.
      serviceName = peerUnitServiceName interfaceName peer.name dynamicRefreshEnabled;
    in
    nameValuePair serviceName {
      after = [
        "wireguard-${interfaceName}.service"
        "network-online.target"
      ];

      description =
        "WireGuard Peer - ${interfaceName} - ${peer.name}"
        + optionalString (peer.name != peer.publicKey) " (${peer.publicKey})";

      environment.DEVICE = interfaceName;
      environment.WG_ENDPOINT_RESOLUTION_RETRIES = "infinity";

      path = with pkgs; [
        iproute2
        wgPackages.${interfaceCfg.type}
      ];

      postStop =
        let
          route_destroy = optionalString interfaceCfg.allowedIPsAsRoutes (
            concatMapStringsSep "\n" (
              allowedIP:
              ''${ip} route delete "${allowedIP}" dev "${interfaceName}" table "${interfaceCfg.table}"''
            ) peer.allowedIPs
          );
        in
        ''
          ${wg} set "${interfaceName}" peer "${peer.publicKey}" remove
          ${route_destroy}
        '';

      requires = [ "wireguard-${interfaceName}.service" ];

      script =
        let
          wg_setup = concatStringsSep " " (
            [ ''${wg} set ${interfaceName} peer "${peer.publicKey}"'' ]
            ++ optional (psk != null) ''preshared-key "${psk}"''
            ++ optional (peer.endpoint != null) ''endpoint "${peer.endpoint}"''
            ++ optional (
              peer.persistentKeepalive != null
            ) ''persistent-keepalive "${toString peer.persistentKeepalive}"''
            ++ optional (peer.allowedIPs != [ ]) ''allowed-ips "${concatStringsSep "," peer.allowedIPs}"''
          );
          route_setup = optionalString interfaceCfg.allowedIPsAsRoutes (
            concatMapStringsSep "\n" (
              allowedIP:
              ''${ip} route replace "${allowedIP}" dev "${interfaceName}" table "${interfaceCfg.table}" ${
                optionalString (interfaceCfg.metric != null) "metric ${toString interfaceCfg.metric}"
              }''
            ) peer.allowedIPs
          );
        in
        ''
          ${wg_setup}
          ${route_setup}

          ${optionalString (dynamicEndpointRefreshSeconds != 0) ''
            # Re-execute 'wg' periodically to notice DNS / hostname changes.
            # Note this will not time out on transient DNS failures such as DNS names
            # because we have set 'WG_ENDPOINT_RESOLUTION_RETRIES=infinity'.
            # Also note that 'wg' limits its maximum retry delay to 20 seconds as of writing.
            while ${wg_setup}; do
              sleep "${toString dynamicEndpointRefreshSeconds}";
            done
          ''}
        '';

      serviceConfig =
        if !dynamicRefreshEnabled then
          {
            RemainAfterExit = true;
            Type = "oneshot";
          }
        else
          {
            # Note that `Type = "oneshot"` services with `RemainAfterExit = true`
            # cannot be used with systemd timers (see `man systemd.timer`),
            # which is why `simple` with a loop is the best choice here.
            # It also makes starting and stopping easiest.
            #
            # Restart if the service exits (e.g. when wireguard gives up after "Name or service not known" dns failures):
            Restart = "always";

            RestartSec =
              if null != peer.dynamicEndpointRefreshRestartSeconds then
                peer.dynamicEndpointRefreshRestartSeconds
              else
                dynamicEndpointRefreshSeconds;

            Type = "simple"; # re-executes 'wg' indefinitely
          };

      unitConfig = lib.optionalAttrs dynamicRefreshEnabled {
        StartLimitIntervalSec = 0;
      };

      wantedBy = [ "wireguard-${interfaceName}.service" ];
      wants = [ "network-online.target" ];
    };

  # the target is required to start new peer units when they are added
  generateInterfaceTarget =
    name: values:
    let
      mkPeerUnit =
        peer: (peerUnitServiceName name peer.name (dynamicRefreshSeconds values peer != 0)) + ".service";
    in
    nameValuePair "wireguard-${name}" rec {
      after = wants;
      description = "WireGuard Tunnel - ${name}";
      wantedBy = [ "multi-user.target" ];
      wants = [ "wireguard-${name}.service" ] ++ map mkPeerUnit values.peers;
    };

  generateInterfaceUnit =
    name: values:
    # exactly one way to specify the private key must be set
    #assert (values.privateKey != null) != (values.privateKeyFile != null);
    let
      privKey =
        if values.privateKeyFile != null then
          values.privateKeyFile
        else
          pkgs.writeText "wg-key" values.privateKey;
      src = values.socketNamespace;
      dst = values.interfaceNamespace;
      ipPreMove = nsWrap "ip" src null;
      ipPostMove = nsWrap "ip" src dst;
      wg = nsWrap wgBins.${values.type} src dst;
      ns = if dst == "init" then "1" else dst;

    in
    nameValuePair "wireguard-${name}" {
      after = [ "network-pre.target" ];
      before = [ "network.target" ];
      description = "WireGuard Tunnel - ${name}";
      environment.DEVICE = name;

      path = with pkgs; [
        kmod
        iproute2
        wgPackages.${values.type}
      ];

      postStop = ''
        ${values.preShutdown}
        ${ipPostMove} link del dev "${name}"
        ${values.postShutdown}
      '';

      script = concatStringsSep "\n" (
        optional (!config.boot.isContainer) "modprobe ${values.type} || true"
        ++ [
          values.preSetup
          ''${ipPreMove} link add dev "${name}" type ${values.type}''
        ]
        ++ optional (
          values.interfaceNamespace != null && values.interfaceNamespace != values.socketNamespace
        ) ''${ipPreMove} link set "${name}" netns "${ns}"''
        ++ optional (values.mtu != null) ''${ipPostMove} link set "${name}" mtu ${toString values.mtu}''
        ++ (map (ip: ''${ipPostMove} address add "${ip}" dev "${name}"'') values.ips)
        ++ [
          (concatStringsSep " " (
            [ ''${wg} set "${name}" private-key "${privKey}"'' ]
            ++ optional (values.listenPort != null) ''listen-port "${toString values.listenPort}"''
            ++ optional (values.fwMark != null) ''fwmark "${values.fwMark}"''
            ++ mapAttrsToList (k: v: ''${toLower k} "${toString v}"'') values.extraOptions
          ))
          ''${ipPostMove} link set up dev "${name}"''
          values.postSetup
        ]
      );

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wants = [ "network.target" ];
    };

  nsWrap =
    cmd: src: dst:
    let
      nsList = filter (ns: ns != null) [
        src
        dst
      ];
      ns = last nsList;
    in
    if (length nsList > 0 && ns != "init") then ''ip netns exec "${ns}" "${cmd}"'' else cmd;

  usingWg = any (x: x.type == "wireguard") (attrValues cfg.interfaces);
  usingAwg = any (x: x.type == "amneziawg") (attrValues cfg.interfaces);
in

{

  ###### interface

  options = {

    networking.wireguard = {

      enable = mkOption {
        # 2019-05-25: Backwards compatibility.
        default = cfg.interfaces != { };
        defaultText = literalExpression "config.${opt.interfaces} != { }";

        description = ''
          Whether to enable WireGuard.

          ::: {.note}
          By default, this module is powered by a script-based backend. You can
          enable the networkd backend with {option}`networking.wireguard.useNetworkd`.
          :::
        '';

        example = true;
        type = types.bool;
      };

      interfaces = mkOption {
        default = { };

        description = ''
          WireGuard interfaces.
        '';

        example = {
          wg0 = {
            ips = [ "192.168.20.4/24" ];

            peers = [
              {
                allowedIPs = [ "192.168.20.1/32" ];
                endpoint = "demo.wireguard.io:12913";
                publicKey = "xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=";
              }
            ];

            privateKey = "yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=";
          };
        };

        type = with types; attrsOf (submodule interfaceOpts);
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable (
    let
      all_peers = flatten (
        mapAttrsToList (
          interfaceName: interfaceCfg:
          map (peer: { inherit interfaceName interfaceCfg peer; }) interfaceCfg.peers
        ) cfg.interfaces
      );
    in
    {

      assertions =
        (attrValues (
          mapAttrs (name: value: {
            assertion = (value.privateKey != null) != (value.privateKeyFile != null);
            message = "Either networking.wireguard.interfaces.${name}.privateKey or networking.wireguard.interfaces.${name}.privateKeyFile must be set.";
          }) cfg.interfaces
        ))
        ++ (attrValues (
          mapAttrs (name: value: {
            assertion = value.generatePrivateKeyFile -> (value.privateKey == null);
            message = "networking.wireguard.interfaces.${name}.generatePrivateKeyFile must not be set if networking.wireguard.interfaces.${name}.privateKey is set.";
          }) cfg.interfaces
        ))
        ++ map (
          { interfaceName, peer, ... }:
          {
            assertion = (peer.presharedKey == null) || (peer.presharedKeyFile == null);
            message = "networking.wireguard.interfaces.${interfaceName} peer «${peer.publicKey}» has both presharedKey and presharedKeyFile set, but only one can be used.";
          }
        ) all_peers;

      boot.extraModulePackages =
        optional (usingWg && (versionOlder kernel.kernel.version "5.6")) kernel.wireguard
        ++ optional usingAwg kernel.amneziawg;

      boot.kernelModules = optional usingWg "wireguard" ++ optional usingAwg "amneziawg";

      environment.systemPackages =
        optional usingWg pkgs.wireguard-tools ++ optional usingAwg pkgs.amneziawg-tools;

      systemd.services = mkIf (!cfg.useNetworkd) (
        (mapAttrs' generateInterfaceUnit cfg.interfaces)
        // (listToAttrs (map generatePeerUnit all_peers))
        // (mapAttrs' generateKeyServiceUnit (
          filterAttrs (name: value: value.generatePrivateKeyFile) cfg.interfaces
        ))
      );

      systemd.targets = mkIf (!cfg.useNetworkd) (mapAttrs' generateInterfaceTarget cfg.interfaces);
    }
  );

}
