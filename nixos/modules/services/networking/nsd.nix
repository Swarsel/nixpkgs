{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.nsd;

  username = "nsd";
  stateDir = "/var/lib/nsd";
  pidFile = stateDir + "/var/nsd.pid";

  # build nsd with the options needed for the given config
  nsdPkg = pkgs.nsd.override {
    bind8Stats = cfg.bind8Stats;
    ipv6 = cfg.ipv6;
    ratelimit = cfg.ratelimit.enable;
    rootServer = cfg.rootServer;
    zoneStats = length (collect (x: (x.zoneStats or null) != null) cfg.zones) > 0;
  };

  mkZoneFileName = name: if name == "." then "root" else name;

  # replaces include: directives for keys with fake keys for nsd-checkconf
  injectFakeKeys =
    keys:
    concatStrings (
      mapAttrsToList (keyName: keyOptions: ''
        fakeKey="$(${pkgs.bind}/bin/tsig-keygen -a ${
          escapeShellArgs [
            keyOptions.algorithm
            keyName
          ]
        } | grep -oP "\s*secret \"\K.*(?=\";)")"
        sed "s@^\s*include:\s*\"${stateDir}/private/${keyName}\"\$@secret: $fakeKey@" -i $out/nsd.conf
      '') keys
    );

  nsdEnv = pkgs.buildEnv {
    name = "nsd-env";
    paths = [ configFile ] ++ mapAttrsToList (name: zone: writeZoneData name zone.data) zoneConfigs;

    postBuild = ''
      echo "checking zone files"
      cd $out/zones

      for zoneFile in *; do
        echo "|- checking zone '$out/zones/$zoneFile'"
        ${nsdPkg}/sbin/nsd-checkzone "$zoneFile" "$zoneFile" || {
          if grep -q \\\\\\$ "$zoneFile"; then
            echo zone "$zoneFile" contains escaped dollar signs \\\$
            echo Escaping them is not needed any more. Please make sure \
                 to unescape them where they prefix a variable name.
          fi

          exit 1
        }
      done

      echo "checking configuration file"
      # Save original config file including key references...
      cp $out/nsd.conf{,.orig}
      # ...inject mock keys into config
      ${injectFakeKeys cfg.keys}
      # ...do the checkconf
      ${nsdPkg}/sbin/nsd-checkconf $out/nsd.conf
      # ... and restore original config file.
      mv $out/nsd.conf{.orig,}
    '';
  };

  writeZoneData =
    name: text:
    pkgs.writeTextFile {
      inherit text;
      destination = "/zones/${mkZoneFileName name}";
      name = "nsd-zone-${mkZoneFileName name}";
    };

  # options are ordered alphanumerically by the nixos option name
  configFile = pkgs.writeTextDir "nsd.conf" ''
    server:
      chroot:   "${stateDir}"
      username: ${username}

      # The directory for zonefile: files. The daemon chdirs here.
      zonesdir: "${stateDir}"

      # the list of dynamically added zones.
      pidfile:      "${pidFile}"
      xfrdfile:     "${stateDir}/var/xfrd.state"
      xfrdir:       "${stateDir}/tmp"
      zonelistfile: "${stateDir}/var/zone.list"

      # interfaces
    ${forEach "  ip-address: " cfg.interfaces}

      ip-freebind:         ${boolToYesNo cfg.ipFreebind}
      hide-version:        ${boolToYesNo cfg.hideVersion}
      identity:            "${cfg.identity}"
      ip-transparent:      ${boolToYesNo cfg.ipTransparent}
      do-ip4:              ${boolToYesNo cfg.ipv4}
      ipv4-edns-size:      ${toString cfg.ipv4EDNSSize}
      do-ip6:              ${boolToYesNo cfg.ipv6}
      ipv6-edns-size:      ${toString cfg.ipv6EDNSSize}
      log-time-ascii:      ${boolToYesNo cfg.logTimeAscii}
      ${maybeString "nsid: " cfg.nsid}
      port:                ${toString cfg.port}
      reuseport:           ${boolToYesNo cfg.reuseport}
      round-robin:         ${boolToYesNo cfg.roundRobin}
      server-count:        ${toString cfg.serverCount}
      ${maybeToString "statistics: " cfg.statistics}
      tcp-count:           ${toString cfg.tcpCount}
      tcp-query-count:     ${toString cfg.tcpQueryCount}
      tcp-timeout:         ${toString cfg.tcpTimeout}
      verbosity:           ${toString cfg.verbosity}
      ${maybeString "version: " cfg.version}
      xfrd-reload-timeout: ${toString cfg.xfrdReloadTimeout}
      zonefiles-check:     ${boolToYesNo cfg.zonefilesCheck}
      zonefiles-write:     ${toString cfg.zonefilesWrite}

      ${maybeString "rrl-ipv4-prefix-length: " cfg.ratelimit.ipv4PrefixLength}
      ${maybeString "rrl-ipv6-prefix-length: " cfg.ratelimit.ipv6PrefixLength}
      rrl-ratelimit:           ${toString cfg.ratelimit.ratelimit}
      ${maybeString "rrl-slip: " cfg.ratelimit.slip}
      rrl-size:                ${toString cfg.ratelimit.size}
      rrl-whitelist-ratelimit: ${toString cfg.ratelimit.whitelistRatelimit}

    ${keyConfigFile}

    remote-control:
      control-enable:    ${boolToYesNo cfg.remoteControl.enable}
      control-key-file:  "${cfg.remoteControl.controlKeyFile}"
      control-cert-file: "${cfg.remoteControl.controlCertFile}"
    ${forEach "  control-interface: " cfg.remoteControl.interfaces}
      control-port:      ${toString cfg.remoteControl.port}
      server-key-file:   "${cfg.remoteControl.serverKeyFile}"
      server-cert-file:  "${cfg.remoteControl.serverCertFile}"

    ${concatStrings (mapAttrsToList zoneConfigFile zoneConfigs)}

    ${cfg.extraConfig}
  '';

  maybeString = prefix: x: optionalString (x != null) ''${prefix} "${x}"'';
  maybeToString = prefix: x: optionalString (x != null) "${prefix} ${toString x}";
  forEach = pre: l: concatMapStrings (x: pre + x + "\n") l;

  keyConfigFile = concatStrings (
    mapAttrsToList (keyName: keyOptions: ''
      key:
        name:      "${keyName}"
        algorithm: "${keyOptions.algorithm}"
        include:   "${stateDir}/private/${keyName}"
    '') cfg.keys
  );

  copyKeys = concatStrings (
    mapAttrsToList (keyName: keyOptions: ''
      secret=$(cat "${keyOptions.keyFile}")
      dest="${stateDir}/private/${keyName}"
      install -m 0400 -o "${username}" -g "${username}" <(echo "  secret: \"$secret\"") "$dest"
    '') cfg.keys
  );

  # options are ordered alphanumerically by the nixos option name
  zoneConfigFile = name: zone: ''
    zone:
      name:         "${name}"
      zonefile:     "${stateDir}/zones/${mkZoneFileName name}"
      ${maybeString "outgoing-interface: " zone.outgoingInterface}
    ${forEach "  rrl-whitelist: " zone.rrlWhitelist}
      ${maybeString "zonestats: " zone.zoneStats}

      ${maybeToString "max-refresh-time: " zone.maxRefreshSecs}
      ${maybeToString "min-refresh-time: " zone.minRefreshSecs}
      ${maybeToString "max-retry-time:   " zone.maxRetrySecs}
      ${maybeToString "min-retry-time:   " zone.minRetrySecs}

      allow-axfr-fallback: ${boolToYesNo zone.allowAXFRFallback}
      multi-master-check: ${boolToYesNo zone.multiMasterCheck}
    ${forEach "  allow-notify: " zone.allowNotify}
    ${forEach "  request-xfr: " zone.requestXFR}

    ${forEach "  notify: " zone.notify}
      notify-retry:                        ${toString zone.notifyRetry}
    ${forEach "  provide-xfr: " zone.provideXFR}
  '';

  zoneConfigs = zoneConfigs' { } "" { children = cfg.zones; };

  zoneConfigs' =
    parent: name: zone:
    if
      !(zone ? children) || zone.children == null || zone.children == { }
    # leaf -> actual zone
    then
      listToAttrs [ (nameValuePair name (parent // zone)) ]

    # fork -> pattern
    else
      zipAttrsWith (name: head) (
        mapAttrsToList (
          name: child: zoneConfigs' (parent // zone // { children = { }; }) name child
        ) zone.children
      );

  # options are ordered alphanumerically
  zoneOptions = types.submodule {
    options = {

      allowAXFRFallback = mkOption {
        default = true;

        description = ''
          If NSD as secondary server should be allowed to AXFR if the primary
          server does not allow IXFR.
        '';

        type = types.bool;
      };

      allowNotify = mkOption {
        default = [ ];

        description = ''
          Listed primary servers are allowed to notify this secondary server.

          Format: `<ip> <key-name | NOKEY | BLOCKED>`

          `<ip>` either a plain IPv4/IPv6 address or range.
          Valid patters for ranges:
          * `10.0.0.0/24`: via subnet size
          * `10.0.0.0&255.255.255.0`: via subnet mask
          * `10.0.0.1-10.0.0.254`: via range

          A optional port number could be added with a '@':
          * `2001:1234::1@1234`

          `<key-name | NOKEY | BLOCKED>`
          * `<key-name>` will use the specified TSIG key
          * `NOKEY` no TSIG signature is required
          * `BLOCKED`notifies from non-listed or blocked IPs will be ignored
        '';

        example = [
          "192.0.2.0/24 NOKEY"
          "10.0.0.1-10.0.0.5 my_tsig_key_name"
          "10.0.3.4&255.255.0.0 BLOCKED"
        ];

        type = types.listOf types.str;
      };

      children = mkOption {
        default = { };

        description = ''
          Children zones inherit all options of their parents. Attributes
          defined in a child will overwrite the ones of its parent. Only
          leaf zones will be actually served. This way it's possible to
          define maybe zones which share most attributes without
          duplicating everything. This mechanism replaces nsd's patterns
          in a save and functional way.
        '';

        # TODO: This relies on the fact that `types.anything` doesn't set any
        # values of its own to any defaults, because in the above zoneConfigs',
        # values from children override ones from parents, but only if the
        # attributes are defined. Because of this, we can't replace the element
        # type here with `zoneConfigs`, since that would set all the attributes
        # to default values, breaking the parent inheriting function.
        type = types.attrsOf types.anything;
      };

      data = mkOption {
        default = "";

        description = ''
          The actual zone data. This is the content of your zone file.
          Use imports or pkgs.lib.readFile if you don't want this data in your config file.
        '';

        type = types.lines;
      };

      dnssec = mkEnableOption "DNSSEC";

      dnssecPolicy = {
        algorithm = mkOption {
          default = "RSASHA256";
          description = "Which algorithm to use for DNSSEC";
          type = types.str;
        };

        coverage = mkOption {
          default = "1y";

          description = ''
            The length of time to ensure that keys will be correct; no action will be taken to create new keys to be activated after this time.
          '';

          type = types.str;
        };

        keyttl = mkOption {
          default = "1h";
          description = "TTL for dnssec records";
          type = types.str;
        };

        ksk = mkOption {
          default = {
            keySize = 4096;
            postPublish = "1mo";
            prePublish = "1mo";
            rollPeriod = "0";
          };

          description = "Key policy for key signing keys";
          type = keyPolicy;
        };

        zsk = mkOption {
          default = {
            keySize = 2048;
            postPublish = "1w";
            prePublish = "1w";
            rollPeriod = "1mo";
          };

          description = "Key policy for zone signing keys";
          type = keyPolicy;
        };
      };

      maxRefreshSecs = mkOption {
        default = null;

        description = ''
          Limit refresh time for secondary zones. This is the timer which
          checks to see if the zone has to be refetched when it expires.
          Normally the value from the SOA record is used, but this  option
          restricts that value.
        '';

        type = types.nullOr types.int;
      };

      maxRetrySecs = mkOption {
        default = null;

        description = ''
          Limit retry time for secondary zones. This is the timeout after
          a failed fetch attempt for the zone. Normally the value from
          the SOA record is used, but this option restricts that value.
        '';

        type = types.nullOr types.int;
      };

      minRefreshSecs = mkOption {
        default = null;

        description = ''
          Limit refresh time for secondary zones.
        '';

        type = types.nullOr types.int;
      };

      minRetrySecs = mkOption {
        default = null;

        description = ''
          Limit retry time for secondary zones.
        '';

        type = types.nullOr types.int;
      };

      multiMasterCheck = mkOption {
        default = false;

        description = ''
          If enabled, checks all masters for the last zone version.
          It uses the higher version from all configured masters.
          Useful if you have multiple masters that have different version numbers served.
        '';

        type = types.bool;
      };

      notify = mkOption {
        default = [ ];

        description = ''
          This primary server will notify all given secondary servers about
          zone changes.

          Format: `<ip> <key-name | NOKEY>`

          `<ip>` a plain IPv4/IPv6 address with on optional port number (ip@port)

          `<key-name | NOKEY>`
          - `<key-name>` sign notifies with the specified key
          - `NOKEY` don't sign notifies
        '';

        example = [
          "10.0.0.1@3721 my_key"
          "::5 NOKEY"
        ];

        type = types.listOf types.str;
      };

      notifyRetry = mkOption {
        default = 5;

        description = ''
          Specifies the number of retries for failed notifies. Set this along with notify.
        '';

        type = types.int;
      };

      outgoingInterface = mkOption {
        default = null;

        description = ''
          This address will be used for zone-transfer requests if configured
          as a secondary server or notifications in case of a primary server.
          Supply either a plain IPv4 or IPv6 address with an optional port
          number (ip@port).
        '';

        example = "2000::1@1234";
        type = types.nullOr types.str;
      };

      provideXFR = mkOption {
        default = [ ];

        description = ''
          Allow these IPs and TSIG to transfer zones, addr TSIG|NOKEY|BLOCKED
          address range 192.0.2.0/24, 1.2.3.4&255.255.0.0, 3.0.2.20-3.0.2.40
        '';

        example = [
          "192.0.2.0/24 NOKEY"
          "192.0.2.0/24 my_tsig_key_name"
        ];

        type = types.listOf types.str;
      };

      requestXFR = mkOption {
        default = [ ];

        description = ''
          Format: `[AXFR|UDP] <ip-address> <key-name | NOKEY>`
        '';

        type = types.listOf types.str;
      };

      rrlWhitelist = mkOption {
        default = [ ];

        description = ''
          Whitelists the given rrl-types.
        '';

        type =
          with types;
          listOf (enum [
            "nxdomain"
            "error"
            "referral"
            "any"
            "rrsig"
            "wildcard"
            "nodata"
            "dnskey"
            "positive"
            "all"
          ]);
      };

      zoneStats = mkOption {
        default = null;

        description = ''
          When set to something distinct to null NSD is able to collect
          statistics per zone. All statistics of this zone(s) will be added
          to the group specified by this given name. Use "%s" to use the zones
          name as the group. The groups are output from nsd-control stats
          and stats_noreset.
        '';

        example = "%s";
        type = types.nullOr types.str;
      };
    };
  };

  keyPolicy = types.submodule {
    options = {
      keySize = mkOption {
        description = "Key size in bits";
        type = types.int;
      };

      postPublish = mkOption {
        description = "How long after deactivation to keep a key in the zone";
        type = types.str;
      };

      prePublish = mkOption {
        description = "How long in advance to publish new keys";
        type = types.str;
      };

      rollPeriod = mkOption {
        description = "How frequently to change keys";
        type = types.str;
      };
    };
  };

  dnssecZones = (filterAttrs (n: v: if v ? dnssec then v.dnssec else false) zoneConfigs);

  dnssec = dnssecZones != { };

  dnssecTools = pkgs.bind.override { enablePython = true; };

  signZones = optionalString dnssec ''
    install -m 0600 -o "${username}" -g "${username}" -d "${stateDir}/dnssec"

    ${concatStrings (mapAttrsToList signZone dnssecZones)}
  '';
  signZone = name: zone: ''
    ${dnssecTools}/bin/dnssec-keymgr -g ${dnssecTools}/bin/dnssec-keygen -s ${dnssecTools}/bin/dnssec-settime -K ${stateDir}/dnssec -c ${policyFile name zone.dnssecPolicy} ${name}
    ${dnssecTools}/bin/dnssec-signzone -S -K ${stateDir}/dnssec -o ${name} -O full -N date ${stateDir}/zones/${name}
    ${nsdPkg}/sbin/nsd-checkzone ${name} ${stateDir}/zones/${name}.signed && mv -v ${stateDir}/zones/${name}.signed ${stateDir}/zones/${name}
  '';
  policyFile =
    name: policy:
    pkgs.writeText "${name}.policy" ''
      zone ${name} {
        algorithm ${policy.algorithm};
        key-size zsk ${toString policy.zsk.keySize};
        key-size ksk ${toString policy.ksk.keySize};
        keyttl ${policy.keyttl};
        pre-publish zsk ${policy.zsk.prePublish};
        pre-publish ksk ${policy.ksk.prePublish};
        post-publish zsk ${policy.zsk.postPublish};
        post-publish ksk ${policy.ksk.postPublish};
        roll-period zsk ${policy.zsk.rollPeriod};
        roll-period ksk ${policy.ksk.rollPeriod};
        coverage ${policy.coverage};
      };
    '';
in
{
  # options are ordered alphanumerically
  options.services.nsd = {

    enable = mkEnableOption "NSD authoritative DNS server";
    bind8Stats = mkEnableOption "BIND8 like statistics";

    dnssecInterval = mkOption {
      default = "1h";

      description = ''
        How often to check whether dnssec key rollover is required
      '';

      type = types.str;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        Extra nsd config.
      '';

      type = types.lines;
    };

    hideVersion = mkOption {
      default = true;

      description = ''
        Whether NSD should answer VERSION.BIND and VERSION.SERVER CHAOS class queries.
      '';

      type = types.bool;
    };

    identity = mkOption {
      default = "unidentified server";

      description = ''
        Identify the server (CH TXT ID.SERVER entry).
      '';

      type = types.str;
    };

    interfaces = mkOption {
      default = [
        "127.0.0.0"
        "::1"
      ];

      description = ''
        What addresses the server should listen to.
      '';

      type = types.listOf types.str;
    };

    ipFreebind = mkOption {
      default = false;

      description = ''
        Whether to bind to nonlocal addresses and interfaces that are down.
        Similar to ip-transparent.
      '';

      type = types.bool;
    };

    ipTransparent = mkOption {
      default = false;

      description = ''
        Allow binding to non local addresses.
      '';

      type = types.bool;
    };

    ipv4 = mkOption {
      default = true;

      description = ''
        Whether to listen on IPv4 connections.
      '';

      type = types.bool;
    };

    ipv4EDNSSize = mkOption {
      default = 4096;

      description = ''
        Preferred EDNS buffer size for IPv4.
      '';

      type = types.int;
    };

    ipv6 = mkOption {
      default = true;

      description = ''
        Whether to listen on IPv6 connections.
      '';

      type = types.bool;
    };

    ipv6EDNSSize = mkOption {
      default = 4096;

      description = ''
        Preferred EDNS buffer size for IPv6.
      '';

      type = types.int;
    };

    keys = mkOption {
      default = { };

      description = ''
        Define your TSIG keys here.
      '';

      example = literalExpression ''
        { "tsig.example.org" = {
            algorithm = "hmac-md5";
            keyFile = "/path/to/my/key";
          };
        }
      '';

      type = types.attrsOf (
        types.submodule {
          options = {

            algorithm = mkOption {
              default = "hmac-sha256";

              description = ''
                Authentication algorithm for this key.
              '';

              type = types.str;
            };

            keyFile = mkOption {
              description = ''
                Path to the file which contains the actual base64 encoded
                key. The key will be copied into "${stateDir}/private" before
                NSD starts. The copied file is only accessibly by the NSD
                user.
              '';

              type = types.path;
            };

          };
        }
      );
    };

    logTimeAscii = mkOption {
      default = true;

      description = ''
        Log time in ascii, if false then in unix epoch seconds.
      '';

      type = types.bool;
    };

    nsid = mkOption {
      default = null;

      description = ''
        NSID identity (hex string, or "ascii_somestring").
      '';

      type = types.nullOr types.str;
    };

    port = mkOption {
      default = 53;

      description = ''
        Port the service should bind do.
      '';

      type = types.port;
    };

    ratelimit = {

      enable = mkEnableOption "ratelimit capabilities";

      ipv4PrefixLength = mkOption {
        default = null;

        description = ''
          IPv4 prefix length. Addresses are grouped by netblock.
        '';

        type = types.nullOr types.int;
      };

      ipv6PrefixLength = mkOption {
        default = null;

        description = ''
          IPv6 prefix length. Addresses are grouped by netblock.
        '';

        type = types.nullOr types.int;
      };

      ratelimit = mkOption {
        default = 200;

        description = ''
          Max qps allowed from any query source.
          0 means unlimited. With an verbosity of 2 blocked and
          unblocked subnets will be logged.
        '';

        type = types.int;
      };

      size = mkOption {
        default = 1000000;

        description = ''
          Size of the hashtable. More buckets use more memory but lower
          the chance of hash hash collisions.
        '';

        type = types.int;
      };

      slip = mkOption {
        default = null;

        description = ''
          Number of packets that get discarded before replying a SLIP response.
          0 disables SLIP responses. 1 will make every response a SLIP response.
        '';

        type = types.nullOr types.int;
      };

      whitelistRatelimit = mkOption {
        default = 2000;

        description = ''
          Max qps allowed from whitelisted sources.
          0 means unlimited. Set the rrl-whitelist option for specific
          queries to apply this limit instead of the default to them.
        '';

        type = types.int;
      };

    };

    remoteControl = {

      enable = mkEnableOption "remote control via nsd-control";

      controlCertFile = mkOption {
        default = "/etc/nsd/nsd_control.pem";

        description = ''
          Path to the client certificate signed with the server certificate.
          This file is used by nsd-control and generated by nsd-control-setup.
        '';

        type = types.path;
      };

      controlKeyFile = mkOption {
        default = "/etc/nsd/nsd_control.key";

        description = ''
          Path to the client private key, which is used by nsd-control
          but not by the server. This file is generated by nsd-control-setup.
        '';

        type = types.path;
      };

      interfaces = mkOption {
        default = [
          "127.0.0.1"
          "::1"
        ];

        description = ''
          Which interfaces NSD should bind to for remote control.
        '';

        type = types.listOf types.str;
      };

      port = mkOption {
        default = 8952;

        description = ''
          Port number for remote control operations (uses TLS over TCP).
        '';

        type = types.port;
      };

      serverCertFile = mkOption {
        default = "/etc/nsd/nsd_server.pem";

        description = ''
          Path to the server self signed certificate, which is used by the server
          but and by nsd-control. This file is generated by nsd-control-setup.
        '';

        type = types.path;
      };

      serverKeyFile = mkOption {
        default = "/etc/nsd/nsd_server.key";

        description = ''
          Path to the server private key, which is used by the server
          but not by nsd-control. This file is generated by nsd-control-setup.
        '';

        type = types.path;
      };

    };

    reuseport = mkOption {
      default = pkgs.stdenv.hostPlatform.isLinux;
      defaultText = literalExpression "pkgs.stdenv.hostPlatform.isLinux";

      description = ''
        Whether to enable SO_REUSEPORT on all used sockets. This lets multiple
        processes bind to the same port. This speeds up operation especially
        if the server count is greater than one and makes fast restarts less
        prone to fail
      '';

      type = types.bool;
    };

    rootServer = mkOption {
      default = false;

      description = ''
        Whether this server will be a root server (a DNS root server, you
        usually don't want that).
      '';

      type = types.bool;
    };

    roundRobin = mkEnableOption "round robin rotation of records";

    serverCount = mkOption {
      default = 1;

      description = ''
        Number of NSD servers to fork. Put the number of CPUs to use here.
      '';

      type = types.int;
    };

    statistics = mkOption {
      default = null;

      description = ''
        Statistics are produced every number of seconds. Prints to log.
        If null no statistics are logged.
      '';

      type = types.nullOr types.int;
    };

    tcpCount = mkOption {
      default = 100;

      description = ''
        Maximum number of concurrent TCP connections per server.
      '';

      type = types.int;
    };

    tcpQueryCount = mkOption {
      default = 0;

      description = ''
        Maximum number of queries served on a single TCP connection.
        0 means no maximum.
      '';

      type = types.int;
    };

    tcpTimeout = mkOption {
      default = 120;

      description = ''
        TCP timeout in seconds.
      '';

      type = types.int;
    };

    verbosity = mkOption {
      default = 0;

      description = ''
        Verbosity level.
      '';

      type = types.int;
    };

    version = mkOption {
      default = null;

      description = ''
        The version string replied for CH TXT version.server and version.bind
        queries. Will use the compiled package version on null.
        See hideVersion for enabling/disabling this responses.
      '';

      type = types.nullOr types.str;
    };

    xfrdReloadTimeout = mkOption {
      default = 1;

      description = ''
        Number of seconds between reloads triggered by xfrd.
      '';

      type = types.int;
    };

    zonefilesCheck = mkOption {
      default = true;

      description = ''
        Whether to check mtime of all zone files on start and sighup.
      '';

      type = types.bool;
    };

    zonefilesWrite = mkOption {
      default = 0;

      description = ''
        Write changed secondary zones to their zonefile every N seconds.
        If the zone (pattern) configuration has "" zonefile, it is not written.
        Zones that have received zone transfer updates are written to their zonefile.
        0 disables writing to zone files.
      '';

      type = types.int;
    };

    zones = mkOption {
      default = { };

      description = ''
        Define your zones here. Zones can cascade other zones and therefore
        inherit settings from parent zones. Look at the definition of
        children to learn about inheritance and child zones.
        The given example will define 3 zones (example.(com|org|net).). Both
        example.com. and example.org. inherit their configuration from
        serverGroup1.
      '';

      example = literalExpression ''
        { "serverGroup1" = {
            provideXFR = [ "10.1.2.3 NOKEY" ];
            children = {
              "example.com." = {
                data = '''
                  $ORIGIN example.com.
                  $TTL    86400
                  @ IN SOA a.ns.example.com. admin.example.com. (
                  ...
                ''';
              };
              "example.org." = {
                data = '''
                  $ORIGIN example.org.
                  $TTL    86400
                  @ IN SOA a.ns.example.com. admin.example.com. (
                  ...
                ''';
              };
            };
          };

          "example.net." = {
            provideXFR = [ "10.3.2.1 NOKEY" ];
            data = '''
              ...
            ''';
          };
        }
      '';

      type = types.attrsOf zoneOptions;
    };
  };

  config = mkIf cfg.enable {

    assertions = singleton {
      assertion = zoneConfigs ? "." -> cfg.rootServer;

      message =
        "You have a root zone configured. If this is really what you "
        + "want, please enable 'services.nsd.rootServer'.";
    };

    environment = {
      etc."nsd/nsd.conf".source = "${configFile}/nsd.conf";
      systemPackages = [ nsdPkg ];
    };

    systemd.services.nsd = {
      after = [ "network.target" ];
      description = "NSD authoritative only domain name service";

      preStart = ''
        rm -Rf "${stateDir}/private/"
        rm -Rf "${stateDir}/tmp/"

        install -dm 0700 -o "${username}" -g "${username}" "${stateDir}/private"
        install -dm 0700 -o "${username}" -g "${username}" "${stateDir}/tmp"
        install -dm 0700 -o "${username}" -g "${username}" "${stateDir}/var"

        cat > "${stateDir}/don't touch anything in here" << EOF
        Everything in this directory except NSD's state in var and dnssec
        is automatically generated and will be purged and redeployed by
        the nsd.service pre-start script.
        EOF

        rm -rf "${stateDir}/zones"
        cp -rL "${nsdEnv}/zones" "${stateDir}/zones"

        ${copyKeys}
      '';

      serviceConfig = {
        ExecStart = "${nsdPkg}/sbin/nsd -d -c ${nsdEnv}/nsd.conf";
        PIDFile = pidFile;
        Restart = "always";
        RestartSec = "4s";
        StandardError = "null";
      };

      startLimitBurst = 4;
      startLimitIntervalSec = 5 * 60; # 5 mins
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.nsd-dnssec = mkIf dnssec {
      before = [ "nsd.service" ];
      description = "DNSSEC key rollover";

      postStop = ''
        /run/current-system/systemd/bin/systemctl kill -s SIGHUP nsd.service
      '';

      script = signZones;
      wantedBy = [ "nsd.service" ];
    };

    systemd.timers.nsd-dnssec = mkIf dnssec {
      description = "Automatic DNSSEC key rollover";

      timerConfig = {
        OnActiveSec = cfg.dnssecInterval;
        OnUnitActiveSec = cfg.dnssecInterval;
      };

      wantedBy = [ "nsd.service" ];
    };

    users.groups.${username}.gid = config.ids.gids.nsd;

    users.users.${username} = {
      createHome = true;
      description = "NSD service user";
      group = username;
      home = stateDir;
      uid = config.ids.uids.nsd;
    };

  };
}
