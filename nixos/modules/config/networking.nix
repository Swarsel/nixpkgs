# /etc files related to networking, such as /etc/services.
{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let

  cfg = config.networking;
  opt = options.networking;

  localhostMultiple = lib.any (lib.elem "localhost") (
    lib.attrValues (
      removeAttrs cfg.hosts [
        "127.0.0.1"
        "::1"
      ]
    )
  );

in

{
  imports = [
    (lib.mkRemovedOptionModule [ "networking" "hostConf" ] "Use environment.etc.\"host.conf\" instead.")
  ];

  options = {

    networking.extraHosts = lib.mkOption {
      default = "";

      description = ''
        Additional verbatim entries to be appended to {file}`/etc/hosts`.
        For adding hosts from derivation results, use {option}`networking.hostFiles` instead.
      '';

      example = "192.168.0.1 lanlocalhost";
      type = lib.types.lines;
    };

    networking.hostFiles = lib.mkOption {
      defaultText = lib.literalMD "Hosts from {option}`networking.hosts` and {option}`networking.extraHosts`";

      description = ''
        Files that should be concatenated together to form {file}`/etc/hosts`.
      '';

      example = lib.literalExpression ''[ "''${pkgs.my-blocklist-package}/share/my-blocklist/hosts" ]'';
      type = lib.types.listOf lib.types.path;
    };

    networking.hosts = lib.mkOption {
      description = ''
        Locally defined maps of hostnames to IP addresses.
      '';

      example = lib.literalExpression ''
        {
          "127.0.0.1" = [ "foo.bar.baz" ];
          "192.168.0.2" = [ "fileserver.local" "nameserver.local" ];
        };
      '';

      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    };

    networking.proxy = {

      allProxy = lib.mkOption {
        default = cfg.proxy.default;
        defaultText = lib.literalExpression "config.${opt.proxy.default}";

        description = ''
          This option specifies the all_proxy environment variable.
        '';

        example = "http://127.0.0.1:3128";
        type = lib.types.nullOr lib.types.str;
      };

      default = lib.mkOption {
        default = null;

        description = ''
          This option specifies the default value for httpProxy, httpsProxy, ftpProxy and rsyncProxy.
        '';

        example = "http://127.0.0.1:3128";
        type = lib.types.nullOr lib.types.str;
      };

      envVars = lib.mkOption {
        default = { };

        description = ''
          Environment variables used for the network proxy.
        '';

        internal = true;
        type = lib.types.attrs;
      };

      ftpProxy = lib.mkOption {
        default = cfg.proxy.default;
        defaultText = lib.literalExpression "config.${opt.proxy.default}";

        description = ''
          This option specifies the ftp_proxy environment variable.
        '';

        example = "http://127.0.0.1:3128";
        type = lib.types.nullOr lib.types.str;
      };

      httpProxy = lib.mkOption {
        default = cfg.proxy.default;
        defaultText = lib.literalExpression "config.${opt.proxy.default}";

        description = ''
          This option specifies the http_proxy environment variable.
        '';

        example = "http://127.0.0.1:3128";
        type = lib.types.nullOr lib.types.str;
      };

      httpsProxy = lib.mkOption {
        default = cfg.proxy.default;
        defaultText = lib.literalExpression "config.${opt.proxy.default}";

        description = ''
          This option specifies the https_proxy environment variable.
        '';

        example = "http://127.0.0.1:3128";
        type = lib.types.nullOr lib.types.str;
      };

      noProxy = lib.mkOption {
        default = null;

        description = ''
          This option specifies the no_proxy environment variable.
          If a default proxy is used and noProxy is null,
          then noProxy will be set to 127.0.0.1,localhost.
        '';

        example = "127.0.0.1,localhost,.localdomain";
        type = lib.types.nullOr lib.types.str;
      };

      rsyncProxy = lib.mkOption {
        default = cfg.proxy.default;
        defaultText = lib.literalExpression "config.${opt.proxy.default}";

        description = ''
          This option specifies the rsync_proxy environment variable.
        '';

        example = "http://127.0.0.1:3128";
        type = lib.types.nullOr lib.types.str;
      };
    };

    networking.timeServers = lib.mkOption {
      default = [
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];

      description = ''
        The set of NTP servers from which to synchronise.
      '';

      type = lib.types.listOf lib.types.str;
    };
  };

  config = {

    assertions = [
      {
        assertion = !localhostMultiple;

        message = ''
          `networking.hosts` maps "localhost" to something other than "127.0.0.1"
          or "::1". This will break some applications. Please use
          `networking.extraHosts` if you really want to add such a mapping.
        '';
      }
    ];

    environment.etc = {
      # /etc/host.conf: resolver configuration file
      "host.conf".text = ''
        multi on
      '';

      # /etc/hosts: Hostname-to-IP mappings.
      hosts.source = pkgs.concatText "hosts" cfg.hostFiles;
      # /etc/netgroup: Network-wide groups.
      netgroup.text = lib.mkDefault "";
      # /etc/protocols: IP protocol numbers.
      protocols.source = pkgs.iana-etc + "/etc/protocols";
      # /etc/services: TCP/UDP port assignments.
      services.source = pkgs.iana-etc + "/etc/services";

    }
    // lib.optionalAttrs (pkgs.stdenv.hostPlatform.libc == "glibc") {
      # /etc/rpc: RPC program numbers.
      rpc.source = pkgs.stdenv.cc.libc.out + "/etc/rpc";
    };

    # Install the proxy environment variables
    environment.sessionVariables = cfg.proxy.envVars;

    networking.hostFiles =
      let
        # Note: localhostHosts has to appear first in /etc/hosts so that 127.0.0.1
        # resolves back to "localhost" (as some applications assume) instead of
        # the FQDN! By default "networking.hosts" also contains entries for the
        # FQDN so that e.g. "hostname -f" works correctly.
        localhostHosts = pkgs.writeText "localhost-hosts" ''
          127.0.0.1 localhost
          ${lib.optionalString cfg.enableIPv6 "::1 localhost"}
        '';
        stringHosts =
          let
            oneToString = set: ip: ip + " " + lib.concatStringsSep " " set.${ip} + "\n";
            allToString = set: lib.concatMapStrings (oneToString set) (lib.attrNames set);
          in
          pkgs.writeText "string-hosts" (allToString (lib.filterAttrs (_: v: v != [ ]) cfg.hosts));
        extraHosts = pkgs.writeText "extra-hosts" cfg.extraHosts;
      in
      lib.mkBefore [
        localhostHosts
        stringHosts
        extraHosts
      ];

    # These entries are required for "hostname -f" and to resolve both the
    # hostname and FQDN correctly:
    networking.hosts =
      let
        hostnames = # Note: The FQDN (canonical hostname) has to come first:
          lib.optional (cfg.hostName != "" && cfg.domain != null) "${cfg.hostName}.${cfg.domain}"
          ++ lib.optional (cfg.hostName != "") cfg.hostName; # Then the hostname (without the domain)
      in
      {
        "127.0.0.2" = hostnames;
      };

    networking.proxy.envVars =
      lib.optionalAttrs (cfg.proxy.default != null) {
        # other options already fallback to proxy.default
        no_proxy = "127.0.0.1,localhost";
      }
      // lib.optionalAttrs (cfg.proxy.httpProxy != null) {
        http_proxy = cfg.proxy.httpProxy;
      }
      // lib.optionalAttrs (cfg.proxy.httpsProxy != null) {
        https_proxy = cfg.proxy.httpsProxy;
      }
      // lib.optionalAttrs (cfg.proxy.rsyncProxy != null) {
        rsync_proxy = cfg.proxy.rsyncProxy;
      }
      // lib.optionalAttrs (cfg.proxy.ftpProxy != null) {
        ftp_proxy = cfg.proxy.ftpProxy;
      }
      // lib.optionalAttrs (cfg.proxy.allProxy != null) {
        all_proxy = cfg.proxy.allProxy;
      }
      // lib.optionalAttrs (cfg.proxy.noProxy != null) {
        no_proxy = cfg.proxy.noProxy;
      };

  };

}
