{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfgs = config.services;
  cfg = cfgs.ncdns;

  dataDir = "/var/lib/ncdns";

  format = pkgs.formats.toml { };

  defaultFiles = {
    private = "${dataDir}/bit.private";
    public = "${dataDir}/bit.key";
    zonePrivate = "${dataDir}/bit-zone.private";
    zonePublic = "${dataDir}/bit-zone.key";
  };

  # if all keys are the default value
  needsKeygen = lib.all lib.id (
    lib.flip lib.mapAttrsToList cfg.dnssec.keys (n: v: v == lib.getAttr n defaultFiles)
  );

  mkDefaultAttrs = lib.mapAttrs (_n: v: lib.mkDefault v);

in

{

  ###### interface

  options = {

    services.ncdns = {

      enable = lib.mkEnableOption ''
        ncdns, a Go daemon to bridge Namecoin to DNS.
        To resolve .bit domains set `services.namecoind.enable = true;`
        and an RPC username/password
      '';

      address = lib.mkOption {
        default = "[::1]";

        description = ''
          The IP address the ncdns resolver will bind to.  Leave this unchanged
          if you do not wish to directly expose the resolver.
        '';

        type = lib.types.str;
      };

      dnssec.enable = lib.mkEnableOption ''
        DNSSEC support in ncdns. This will generate KSK and ZSK keypairs
        (unless provided via the options
        {option}`services.ncdns.dnssec.publicKey`,
        {option}`services.ncdns.dnssec.privateKey` etc.) and add a trust
        anchor to recursive resolvers
      '';

      dnssec.keys.private = lib.mkOption {
        default = defaultFiles.private;

        description = ''
          Path to the file containing the KSK private key.
        '';

        type = lib.types.path;
      };

      dnssec.keys.public = lib.mkOption {
        default = defaultFiles.public;

        description = ''
          Path to the file containing the KSK public key.
          The key can be generated using the `dnssec-keygen`
          command, provided by the package `bind` as follows:
          ```
          $ dnssec-keygen -a RSASHA256 -3 -b 2048 -f KSK bit
          ```
        '';

        type = lib.types.path;
      };

      dnssec.keys.zonePrivate = lib.mkOption {
        default = defaultFiles.zonePrivate;

        description = ''
          Path to the file containing the ZSK private key.
        '';

        type = lib.types.path;
      };

      dnssec.keys.zonePublic = lib.mkOption {
        default = defaultFiles.zonePublic;

        description = ''
          Path to the file containing the ZSK public key.
          The key can be generated using the `dnssec-keygen`
          command, provided by the package `bind` as follows:
          ```
          $ dnssec-keygen -a RSASHA256 -3 -b 2048 bit
          ```
        '';

        type = lib.types.path;
      };

      identity.address = lib.mkOption {
        default = "127.127.127.127";

        description = ''
          The IP address the hostname specified in
          {option}`services.ncdns.identity.hostname` should resolve to.
          If you are only using ncdns locally you can ignore this.
        '';

        type = lib.types.str;
      };

      identity.hostmaster = lib.mkOption {
        default = "";

        description = ''
          An email address for the SOA record at the bit zone.
          If you are only using ncdns locally you can ignore this.
        '';

        example = "root@example.com";
        type = lib.types.str;
      };

      identity.hostname = lib.mkOption {
        default = config.networking.hostName;
        defaultText = lib.literalExpression "config.networking.hostName";

        description = ''
          The hostname of this ncdns instance, which defaults to the machine
          hostname. If specified, ncdns lists the hostname as an NS record at
          the zone apex:
          ```
          bit. IN NS ns1.example.com.
          ```
          If unset ncdns will generate an internal pseudo-hostname under the
          zone, which will resolve to the value of
          {option}`services.ncdns.identity.address`.
          If you are only using ncdns locally you can ignore this.
        '';

        example = "example.com";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 5333;

        description = ''
          The port the ncdns resolver will bind to.
        '';

        type = lib.types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          ncdns settings. Use this option to configure ncds
          settings not exposed in a NixOS option or to bypass one.
          See the example ncdns.conf file at <https://github.com/namecoin/ncdns/blob/master/_doc/ncdns.conf.example>
          for the available options.
        '';

        example = lib.literalExpression ''
          { # enable webserver
            ncdns.httplistenaddr = ":8202";

            # synchronize TLS certs
            certstore.nss = true;
            # note: all paths are relative to the config file
            certstore.nsscertdir =  "../../var/lib/ncdns";
            certstore.nssdbdir = "../../home/alice/.pki/nssdb";
          }
        '';

        type = format.type;
      };

    };

    services.pdns-recursor.resolveNamecoin = lib.mkOption {
      default = false;

      description = ''
        Resolve `.bit` top-level domains using ncdns and namecoin.
      '';

      type = lib.types.bool;
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    services.ncdns.settings = mkDefaultAttrs {
      ncdns = {
        # Other
        bind = "${cfg.address}:${toString cfg.port}";
        hostmaster = cfg.identity.hostmaster;
        # Namecoin RPC
        namecoinrpcaddress = "${cfgs.namecoind.rpc.address}:${toString cfgs.namecoind.rpc.port}";
        namecoinrpcpassword = cfgs.namecoind.rpc.password;
        namecoinrpcusername = cfgs.namecoind.rpc.user;
        selfip = cfg.identity.address;
        # Identity
        selfname = cfg.identity.hostname;
      }
      // lib.optionalAttrs cfg.dnssec.enable {
        privatekey = "../.." + cfg.dnssec.keys.private;
        # DNSSEC
        publickey = "../.." + cfg.dnssec.keys.public;
        zoneprivatekey = "../.." + cfg.dnssec.keys.zonePrivate;
        zonepublickey = "../.." + cfg.dnssec.keys.zonePublic;
      };

      # Daemon
      service.daemon = true;
      xlog.journal = true;
    };

    services.pdns-recursor = lib.mkIf cfgs.pdns-recursor.resolveNamecoin {
      forwardZonesRecurse.bit = "${cfg.address}:${toString cfg.port}";

      luaConfig =
        if cfg.dnssec.enable then
          ''readTrustAnchorsFromFile("${cfg.dnssec.keys.public}")''
        else
          ''addNTA("bit", "namecoin DNSSEC disabled")'';
    };

    systemd.services.ncdns = {
      after = [ "namecoind.service" ];
      description = "ncdns daemon";

      preStart = lib.optionalString (cfg.dnssec.enable && needsKeygen) ''
        cd ${dataDir}
        if [ ! -e bit.key ]; then
          ${pkgs.bind}/bin/dnssec-keygen -a RSASHA256 -3 -b 2048 bit
          mv Kbit.*.key bit-zone.key
          mv Kbit.*.private bit-zone.private
          ${pkgs.bind}/bin/dnssec-keygen -a RSASHA256 -3 -b 2048 -f KSK bit
          mv Kbit.*.key bit.key
          mv Kbit.*.private bit.private
        fi
      '';

      serviceConfig = {
        ExecStart = "${pkgs.ncdns}/bin/ncdns -conf=${format.generate "ncdns.conf" cfg.settings}";
        Restart = "on-failure";
        StateDirectory = "ncdns";
        User = "ncdns";
      };

      wantedBy = [ "multi-user.target" ];
    };

    # Avoid pdns-recursor not finding the DNSSEC keys
    systemd.services.pdns-recursor = lib.mkIf cfgs.pdns-recursor.resolveNamecoin {
      after = [ "ncdns.service" ];
      wants = [ "ncdns.service" ];
    };

    users.groups.ncdns = { };

    users.users.ncdns = {
      description = "ncdns daemon user";
      group = "ncdns";
      isSystemUser = true;
    };

  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
