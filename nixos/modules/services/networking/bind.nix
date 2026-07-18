{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.bind;

  bindPkg = config.services.bind.package;

  bindUser = "named";

  bindZoneCoerce =
    list:
    builtins.listToAttrs (
      lib.forEach list (zone: {
        name = zone.name;
        value = zone;
      })
    );

  bindRndcMacType = "hmac-sha256";

  bindRndcKeyFile = "/etc/bind/rndc.key";

  bindNamedExe = lib.getExe' bindPkg "named";

  bindRndcExe = lib.getExe' bindPkg "rndc";

  bindZoneOptions =
    { config, name, ... }:
    {
      options = {
        allowQuery = lib.mkOption {
          default = [ "any" ];

          description = ''
            List of address ranges allowed to query this zone. Instead of the address(es), this may instead
            contain the single string "any".
          '';

          type = lib.types.listOf lib.types.str;
        };

        extraConfig = lib.mkOption {
          default = "";
          description = "Extra zone config to be appended at the end of the zone section.";
          type = lib.types.lines;
        };

        file = lib.mkOption {
          description = "Zone file resource records contain columns of data, separated by whitespace, that define the record.";
          type = lib.types.either lib.types.str lib.types.path;
        };

        master = lib.mkOption {
          description = "Master=false means slave server";
          type = lib.types.bool;
        };

        masters = lib.mkOption {
          description = "List of servers for inclusion in stub and secondary zones.";
          type = lib.types.listOf lib.types.str;
        };

        name = lib.mkOption {
          default = name;
          description = "Name of the zone.";
          type = lib.types.str;
        };

        slaves = lib.mkOption {
          default = [ ];
          description = "Addresses who may request zone transfers.";
          type = lib.types.listOf lib.types.str;
        };
      };
    };

  testRndcKey = pkgs.writeTextFile {
    name = "testrndc.key";

    text = ''
      key "rndc-key" {
        algorithm ${bindRndcMacType};
        secret "Ini0XSebb9LrYz7zprobBLZ2iwBEK5S9vh9zj/DozR8=";
      };
    '';
  };

  testFakeDir = "/tmp/test-fake-directory-for-named-checkconf";

  confFile = pkgs.writeTextFile {
    checkPhase = ''
      ${lib.optionalString cfg.checkConfig ''
        echo "Checking named configuration file...";
        mkdir -p ${testFakeDir}
        ${lib.getExe' bindPkg "named-checkconf"} -z $target
      ''}

      substituteInPlace $target \
        --replace-fail ${testRndcKey} ${bindRndcKeyFile} \
        --replace-fail ${testFakeDir} ${cfg.directory}
    '';

    name = "named.conf";

    # The include path in the first line will be replaced in the postCheck hook.
    text = ''
      include "${testRndcKey}";
      controls {
        inet 127.0.0.1 allow {localhost;} keys {"rndc-key";};
      };

      acl cachenetworks { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.cacheNetworks} };
      acl badnetworks { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.blockedNetworks} };

      options {
        listen-on port ${toString cfg.listenOnPort} { ${
          lib.concatMapStrings (entry: " ${entry}; ") cfg.listenOn
        } };
        listen-on-v6 port ${toString cfg.listenOnIpv6Port} { ${
          lib.concatMapStrings (entry: " ${entry}; ") cfg.listenOnIpv6
        } };
        allow-query-cache { cachenetworks; };
        blackhole { badnetworks; };
        forward ${cfg.forward};
        forwarders { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.forwarders} };
        directory "${testFakeDir}";
        pid-file "/run/named/named.pid";
        ${cfg.extraOptions}
      };

      ${cfg.extraConfig}

      ${lib.concatMapStrings (
        {
          file,
          name,
          allowQuery ? [ ],
          extraConfig ? "",
          master ? true,
          masters ? [ ],
          slaves ? [ ],
        }:
        ''
          zone "${name}" {
            type ${if master then "master" else "slave"};
            file "${file}";
            ${
              if master then
                ''
                  allow-transfer {
                    ${lib.concatMapStrings (ip: "${ip};\n") slaves}
                  };
                ''
              else
                ''
                  masters {
                    ${lib.concatMapStrings (ip: "${ip};\n") masters}
                  };
                ''
            }
            allow-query { ${lib.concatMapStrings (ip: "${ip}; ") allowQuery}};
            ${extraConfig}
          };
        ''
      ) (lib.attrValues cfg.zones)}
    '';
  };
in

{

  ###### interface

  options = {

    services.bind = {

      enable = lib.mkEnableOption "BIND domain name server";
      package = lib.mkPackageOption pkgs "bind" { };

      blockedNetworks = lib.mkOption {
        default = [ ];

        description = ''
          What networks are just blocked.
        '';

        type = lib.types.listOf lib.types.str;
      };

      cacheNetworks = lib.mkOption {
        default = [
          "127.0.0.0/24"
          "::1/128"
        ];

        description = ''
          What networks are allowed to use us as a resolver.  Note
          that this is for recursive queries -- all networks are
          allowed to query zones configured with the `zones` option
          by default (although this may be overridden within each
          zone's configuration, via the `allowQuery` option).
          It is recommended that you limit cacheNetworks to avoid your
          server being used for DNS amplification attacks.
        '';

        type = lib.types.listOf lib.types.str;
      };

      checkConfig = lib.mkOption {
        default = true;

        description = ''
          Check configuration.

          The configuration will not be checked if you override the config file
          with `configFile`.
        '';

        type = lib.types.bool;
      };

      configFile = lib.mkOption {
        default = confFile;
        defaultText = lib.literalExpression "confFile";

        description = ''
          Overridable config file to use for named. By default, that
          generated by nixos. If overriden, it will not be checked by
          named-checkconf.
        '';

        type = lib.types.path;
      };

      directory = lib.mkOption {
        default = "/run/named";
        description = "Working directory of BIND.";
        type = lib.types.str;
      };

      extraArgs = lib.mkOption {
        default = [ ];

        description = ''
          Additional command-line arguments to pass to named.
        '';

        example = [
          "-n"
          "4"
        ];

        type = lib.types.listOf lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Extra lines to be added verbatim to the generated named configuration file.
        '';

        type = lib.types.lines;
      };

      extraOptions = lib.mkOption {
        default = "";

        description = ''
          Extra lines to be added verbatim to the options section of the
          generated named configuration file.
        '';

        type = lib.types.lines;
      };

      forward = lib.mkOption {
        default = "first";

        description = ''
          Whether to forward 'first' (try forwarding but lookup directly if forwarding fails) or 'only'.
        '';

        type = lib.types.enum [
          "first"
          "only"
        ];
      };

      forwarders = lib.mkOption {
        default = config.networking.nameservers;
        defaultText = lib.literalExpression "config.networking.nameservers";

        description = ''
          List of servers we should forward requests to.
        '';

        type = lib.types.listOf lib.types.str;
      };

      ipv4Only = lib.mkOption {
        default = false;

        description = ''
          Only use ipv4, even if the host supports ipv6.
        '';

        type = lib.types.bool;
      };

      listenOn = lib.mkOption {
        default = [ "any" ];

        description = ''
          Interfaces to listen on.
        '';

        type = lib.types.listOf lib.types.str;
      };

      listenOnIpv6 = lib.mkOption {
        default = [ "any" ];

        description = ''
          Ipv6 interfaces to listen on.
        '';

        type = lib.types.listOf lib.types.str;
      };

      listenOnIpv6Port = lib.mkOption {
        default = 53;

        description = ''
          Ipv6 port to listen on.
        '';

        type = lib.types.port;
      };

      listenOnPort = lib.mkOption {
        default = 53;

        description = ''
          Port to listen on.
        '';

        type = lib.types.port;
      };

      zones = lib.mkOption {
        default = [ ];

        description = ''
          List of zones we claim authority over.
        '';

        example = {
          "example.com" = {
            extraConfig = "";
            file = "/var/dns/example.com";
            master = false;
            masters = [ "192.168.0.1" ];
            slaves = [ ];
          };
        };

        type =
          with lib.types;
          coercedTo (listOf attrs) bindZoneCoerce (attrsOf (lib.types.submodule bindZoneOptions));
      };
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    networking.resolvconf.useLocalResolver = lib.mkDefault true;

    systemd.services.bind = {
      after = [ "network.target" ];
      description = "BIND Domain Name Server";

      preStart = ''
        if ! [ -f ${bindRndcKeyFile} ]; then
          ${lib.getExe' bindPkg "rndc-confgen"} -c ${bindRndcKeyFile} -a -A ${bindRndcMacType} 2>/dev/null
        fi
      '';

      serviceConfig = {
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        ConfigurationDirectory = "bind";
        ExecReload = "${bindRndcExe} -k '${bindRndcKeyFile}' reload";
        ExecStart = "${bindNamedExe} ${lib.optionalString cfg.ipv4Only "-4"} -c ${cfg.configFile} ${lib.concatStringsSep " " cfg.extraArgs}";
        ExecStop = "${bindRndcExe} -k '${bindRndcKeyFile}' stop";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        # Security
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        # Sandboxing
        ProtectSystem = "strict";
        ReadOnlyPaths = "/sys";

        ReadWritePaths = [
          (lib.mapAttrsToList (
            name: config: if (lib.hasPrefix "/" config.file) then "-${dirOf config.file}" else ""
          ) cfg.zones)
          cfg.directory
        ];

        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_UNIX AF_INET AF_INET6 AF_NETLINK" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "named";
        RuntimeDirectoryPreserve = "yes";
        # System Call Filtering
        SystemCallArchitectures = "native";
        SystemCallFilter = "~@mount @debug @clock @reboot @resources @privileged @obsolete acct modify_ldt add_key adjtimex clock_adjtime delete_module fanotify_init finit_module get_mempolicy init_module io_destroy io_getevents iopl ioperm io_setup io_submit io_cancel kcmp kexec_load keyctl lookup_dcookie migrate_pages move_pages open_by_handle_at perf_event_open process_vm_readv process_vm_writev ptrace remap_file_pages request_key set_mempolicy swapoff swapon uselib vmsplice";
        Type = "forking"; # Set type to forking, see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=900788
        User = bindUser;
      };

      unitConfig.Documentation = "man:named(8)";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."bind" = lib.mkIf (cfg.directory != "/run/named") {
      ${cfg.directory} = {
        d = {
          age = "-";
          group = bindUser;
          user = bindUser;
        };
      };
    };

    users.groups.${bindUser} = { };

    users.users.${bindUser} = {
      description = "BIND daemon user";
      group = bindUser;
      isSystemUser = true;
    };
  };
}
