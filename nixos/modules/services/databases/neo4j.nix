{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.neo4j;
  opt = options.services.neo4j;
  certDirOpt = options.services.neo4j.directories.certificates;
  isDefaultPathOption =
    opt: lib.isOption opt && opt.type == lib.types.path && opt.highestPrio >= 1500;

  sslPolicies = lib.mapAttrsToList (name: conf: ''
    dbms.ssl.policy.${name}.allow_key_generation=${lib.boolToString conf.allowKeyGeneration}
    dbms.ssl.policy.${name}.base_directory=${conf.baseDirectory}
    ${lib.optionalString (conf.ciphers != null) ''
      dbms.ssl.policy.${name}.ciphers=${lib.concatStringsSep "," conf.ciphers}
    ''}
    dbms.ssl.policy.${name}.client_auth=${conf.clientAuth}
    ${
      if lib.length (lib.splitString "/" conf.privateKey) > 1 then
        "dbms.ssl.policy.${name}.private_key=${conf.privateKey}"
      else
        "dbms.ssl.policy.${name}.private_key=${conf.baseDirectory}/${conf.privateKey}"
    }
    ${
      if lib.length (lib.splitString "/" conf.privateKey) > 1 then
        "dbms.ssl.policy.${name}.public_certificate=${conf.publicCertificate}"
      else
        "dbms.ssl.policy.${name}.public_certificate=${conf.baseDirectory}/${conf.publicCertificate}"
    }
    dbms.ssl.policy.${name}.revoked_dir=${conf.revokedDir}
    dbms.ssl.policy.${name}.tls_versions=${lib.concatStringsSep "," conf.tlsVersions}
    dbms.ssl.policy.${name}.trust_all=${lib.boolToString conf.trustAll}
    dbms.ssl.policy.${name}.trusted_dir=${conf.trustedDir}
  '') cfg.ssl.policies;

  serverConfig = pkgs.writeText "neo4j.conf" ''
    # General
    server.default_listen_address=${cfg.defaultListenAddress}
    server.databases.default_to_read_only=${lib.boolToString cfg.readOnly}
    ${lib.optionalString (cfg.workerCount > 0) ''
      dbms.threads.worker_count=${toString cfg.workerCount}
    ''}

    # Directories (readonly)
    # dbms.directories.certificates=${cfg.directories.certificates}
    server.directories.plugins=${cfg.directories.plugins}
    server.directories.lib=${cfg.package}/share/neo4j/lib
    ${lib.optionalString (cfg.constrainLoadCsv) ''
      server.directories.import=${cfg.directories.imports}
    ''}

    # Directories (read and write)
    server.directories.data=${cfg.directories.data}
    server.directories.logs=${cfg.directories.home}/logs
    server.directories.run=${cfg.directories.home}/run

    # HTTP Connector
    server.http.enabled=${lib.boolToString cfg.http.enable}
    server.http.listen_address=${cfg.http.listenAddress}
    server.http.advertised_address=${cfg.http.advertisedAddress}

    # HTTPS Connector
    server.https.enabled=${lib.boolToString cfg.https.enable}
    server.https.listen_address=${cfg.https.listenAddress}
    server.https.advertised_address=${cfg.https.advertisedAddress}

    # BOLT Connector
    server.bolt.enabled=${lib.boolToString cfg.bolt.enable}
    server.bolt.listen_address=${cfg.bolt.listenAddress}
    server.bolt.advertised_address=${cfg.bolt.advertisedAddress}
    server.bolt.tls_level=${cfg.bolt.tlsLevel}

    # SSL Policies
    ${lib.concatStringsSep "\n" sslPolicies}

    # Default retention policy from neo4j.conf
    db.tx_log.rotation.retention_policy=1 days

    # Default JVM parameters from neo4j.conf
    server.jvm.additional=-XX:+UseG1GC
    server.jvm.additional=-XX:-OmitStackTraceInFastThrow
    server.jvm.additional=-XX:+AlwaysPreTouch
    server.jvm.additional=-XX:+UnlockExperimentalVMOptions
    server.jvm.additional=-XX:+TrustFinalNonStaticFields
    server.jvm.additional=-XX:+DisableExplicitGC
    server.jvm.additional=-Djdk.tls.ephemeralDHKeySize=2048
    server.jvm.additional=-Djdk.tls.rejectClientInitiatedRenegotiation=true
    server.jvm.additional=-Dunsupported.dbms.udc.source=tarball

    #server.memory.off_heap.transaction_max_size=12000m
    #server.memory.heap.max_size=12000m
    #server.memory.pagecache.size=4g
    #server.tx_state.max_off_heap_memory=8000m

    # Extra Configuration
    ${cfg.extraServerConfig}
  '';
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "neo4j" "host" ]
      [ "services" "neo4j" "defaultListenAddress" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "neo4j" "listenAddress" ]
      [ "services" "neo4j" "defaultListenAddress" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "neo4j" "enableBolt" ]
      [ "services" "neo4j" "bolt" "enable" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "neo4j" "enableHttps" ]
      [ "services" "neo4j" "https" "enable" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "neo4j" "certDir" ]
      [ "services" "neo4j" "directories" "certificates" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "neo4j" "dataDir" ]
      [ "services" "neo4j" "directories" "home" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "neo4j"
      "port"
    ] "Use services.neo4j.http.listenAddress instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "neo4j"
      "boltPort"
    ] "Use services.neo4j.bolt.listenAddress instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "neo4j"
      "httpsPort"
    ] "Use services.neo4j.https.listenAddress instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "neo4j"
      "shell"
      "enabled"
    ] "shell.enabled was removed upstream")
    (lib.mkRemovedOptionModule [
      "services"
      "neo4j"
      "udc"
      "enabled"
    ] "udc.enabled was removed upstream")
  ];

  ###### interface

  options.services.neo4j = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable Neo4j Community Edition.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "neo4j" { };

    bolt = {
      enable = lib.mkOption {
        default = true;

        description = ''
          Enable the BOLT connector for Neo4j. Setting this option to
          `false` will stop Neo4j from listening for incoming
          connections on the BOLT port (7687 by default).
        '';

        type = lib.types.bool;
      };

      advertisedAddress = lib.mkOption {
        default = cfg.bolt.listenAddress;
        defaultText = lib.literalExpression "config.${opt.bolt.listenAddress}";

        description = ''
          Neo4j advertised address for BOLT traffic. The advertised address is
          expressed in the format `<ip-address>:<port-number>`.
        '';

        type = lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = ":7687";

        description = ''
          Neo4j listen address for BOLT traffic. The listen address is
          expressed in the format `<ip-address>:<port-number>`.
        '';

        type = lib.types.str;
      };

      sslPolicy = lib.mkOption {
        default = "legacy";

        description = ''
          Neo4j SSL policy for BOLT traffic.

          The legacy policy is a special policy which is not defined in
          the policy configuration section, but rather derives from
          {option}`directories.certificates` and
          associated files (by default: {file}`neo4j.key` and
          {file}`neo4j.cert`). Its use will be deprecated.

          Note: This connector must be configured to support/require
          SSL/TLS for the legacy policy to actually be utilized. See
          {option}`bolt.tlsLevel`.
        '';

        type = lib.types.str;
      };

      tlsLevel = lib.mkOption {
        default = "OPTIONAL";

        description = ''
          SSL/TSL requirement level for BOLT traffic.
        '';

        type = lib.types.enum [
          "REQUIRED"
          "OPTIONAL"
          "DISABLED"
        ];
      };
    };

    constrainLoadCsv = lib.mkOption {
      default = true;

      description = ''
        Sets the root directory for file URLs used with the Cypher
        `LOAD CSV` clause to be that defined by
        {option}`directories.imports`. It restricts
        access to only those files within that directory and its
        subdirectories.

        Setting this option to `false` introduces
        possible security problems.
      '';

      type = lib.types.bool;
    };

    defaultListenAddress = lib.mkOption {
      default = "127.0.0.1";

      description = ''
        Default network interface to listen for incoming connections. To
        listen for connections on all interfaces, use "0.0.0.0".

        Specifies the default IP address and address part of connector
        specific {option}`listenAddress` options. To bind specific
        connectors to a specific network interfaces, specify the entire
        {option}`listenAddress` option for that connector.
      '';

      type = lib.types.str;
    };

    directories = {
      imports = lib.mkOption {
        default = "${cfg.directories.home}/import";
        defaultText = lib.literalExpression ''"''${config.${opt.directories.home}}/import"'';

        description = ''
          The root directory for file URLs used with the Cypher
          `LOAD CSV` clause. Only meaningful when
          {option}`constrainLoadCvs` is set to
          `true`.

          When setting this directory to something other than its default,
          ensure the directory's existence, and that read permission is
          given to the Neo4j daemon user `neo4j`.
        '';

        type = lib.types.path;
      };

      certificates = lib.mkOption {
        default = "${cfg.directories.home}/certificates";
        defaultText = lib.literalExpression ''"''${config.${opt.directories.home}}/certificates"'';

        description = ''
          Directory for storing certificates to be used by Neo4j for
          TLS connections.

          When setting this directory to something other than its default,
          ensure the directory's existence, and that read/write permissions are
          given to the Neo4j daemon user `neo4j`.

          Note that changing this directory from its default will prevent
          the directory structure required for each SSL policy from being
          automatically generated. A policy's directory structure as defined by
          its {option}`baseDirectory`,{option}`revokedDir` and
          {option}`trustedDir` must then be setup manually. The
          existence of these directories is mandatory, as well as the presence
          of the certificate file and the private key. Ensure the correct
          permissions are set on these directories and files.
        '';

        type = lib.types.path;
      };

      data = lib.mkOption {
        default = "${cfg.directories.home}/data";
        defaultText = lib.literalExpression ''"''${config.${opt.directories.home}}/data"'';

        description = ''
          Path of the data directory. You must not configure more than one
          Neo4j installation to use the same data directory.

          When setting this directory to something other than its default,
          ensure the directory's existence, and that read/write permissions are
          given to the Neo4j daemon user `neo4j`.
        '';

        type = lib.types.path;
      };

      home = lib.mkOption {
        default = "/var/lib/neo4j";

        description = ''
          Path of the Neo4j home directory. Other default directories are
          subdirectories of this path. This directory will be created if
          non-existent, and its ownership will be {command}`chown` to
          the Neo4j daemon user `neo4j`.
        '';

        type = lib.types.path;
      };

      plugins = lib.mkOption {
        default = "${cfg.directories.home}/plugins";
        defaultText = lib.literalExpression ''"''${config.${opt.directories.home}}/plugins"'';

        description = ''
          Path of the database plugin directory. Compiled Java JAR files that
          contain database procedures will be loaded if they are placed in
          this directory.

          When setting this directory to something other than its default,
          ensure the directory's existence, and that read permission is
          given to the Neo4j daemon user `neo4j`.
        '';

        type = lib.types.path;
      };
    };

    extraServerConfig = lib.mkOption {
      default = "";

      description = ''
        Extra configuration for Neo4j Community server. Refer to the
        [complete reference](https://neo4j.com/docs/operations-manual/current/reference/configuration-settings/)
        of Neo4j configuration settings.
      '';

      type = lib.types.lines;
    };

    http = {
      enable = lib.mkOption {
        default = true;

        description = ''
          Enable the HTTP connector for Neo4j. Setting this option to
          `false` will stop Neo4j from listening for incoming
          connections on the HTTPS port (7474 by default).
        '';

        type = lib.types.bool;
      };

      advertisedAddress = lib.mkOption {
        default = cfg.http.listenAddress;
        defaultText = lib.literalExpression "config.${opt.http.listenAddress}";

        description = ''
          Neo4j advertised address for HTTP traffic. The advertised address is
          expressed in the format `<ip-address>:<port-number>`.
        '';

        type = lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = ":7474";

        description = ''
          Neo4j listen address for HTTP traffic. The listen address is
          expressed in the format `<ip-address>:<port-number>`.
        '';

        type = lib.types.str;
      };
    };

    https = {
      enable = lib.mkOption {
        default = true;

        description = ''
          Enable the HTTPS connector for Neo4j. Setting this option to
          `false` will stop Neo4j from listening for incoming
          connections on the HTTPS port (7473 by default).
        '';

        type = lib.types.bool;
      };

      advertisedAddress = lib.mkOption {
        default = cfg.https.listenAddress;
        defaultText = lib.literalExpression "config.${opt.https.listenAddress}";

        description = ''
          Neo4j advertised address for HTTPS traffic. The advertised address is
          expressed in the format `<ip-address>:<port-number>`.
        '';

        type = lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = ":7473";

        description = ''
          Neo4j listen address for HTTPS traffic. The listen address is
          expressed in the format `<ip-address>:<port-number>`.
        '';

        type = lib.types.str;
      };

      sslPolicy = lib.mkOption {
        default = "legacy";

        description = ''
          Neo4j SSL policy for HTTPS traffic.

          The legacy policy is a special policy which is not defined in the
          policy configuration section, but rather derives from
          {option}`directories.certificates` and
          associated files (by default: {file}`neo4j.key` and
          {file}`neo4j.cert`). Its use will be deprecated.
        '';

        type = lib.types.str;
      };
    };

    readOnly = lib.mkOption {
      default = false;

      description = ''
        Only allow read operations from this Neo4j instance.
      '';

      type = lib.types.bool;
    };

    shell = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enable a remote shell server which Neo4j Shell clients can log in to.
          Only applicable to {command}`neo4j-shell`.
        '';

        type = lib.types.bool;
      };
    };

    ssl.policies = lib.mkOption {
      default = { };

      description = ''
        Defines the SSL policies for use with Neo4j connectors. Each attribute
        of this set defines a policy, with the attribute name defining the name
        of the policy and its namespace. Refer to the operations manual section
        on Neo4j's
        [SSL Framework](https://neo4j.com/docs/operations-manual/current/security/ssl-framework/)
        for further details.
      '';

      type =
        with lib.types;
        attrsOf (
          submodule (
            {
              config,
              options,
              name,
              ...
            }:
            {
              options = {
                allowKeyGeneration = lib.mkOption {
                  default = false;

                  description = ''
                    Allows the generation of a private key and associated self-signed
                    certificate. Only performed when both objects cannot be found for
                    this policy. It is recommended to turn this off again after keys
                    have been generated.

                    The public certificate is required to be duplicated to the
                    directory holding trusted certificates as defined by the
                    {option}`trustedDir` option.

                    Keys should in general be generated and distributed offline by a
                    trusted certificate authority and not by utilizing this mode.
                  '';

                  type = lib.types.bool;
                };

                baseDirectory = lib.mkOption {
                  default = "${cfg.directories.certificates}/${name}";
                  defaultText = lib.literalExpression ''"''${config.${opt.directories.certificates}}/''${name}"'';

                  description = ''
                    The mandatory base directory for cryptographic objects of this
                    policy. This path is only automatically generated when this
                    option as well as {option}`directories.certificates` are
                    left at their default. Ensure read/write permissions are given
                    to the Neo4j daemon user `neo4j`.

                    It is also possible to override each individual
                    configuration with absolute paths. See the
                    {option}`privateKey` and {option}`publicCertificate`
                    policy options.
                  '';

                  type = lib.types.path;
                };

                ciphers = lib.mkOption {
                  default = null;

                  description = ''
                    Restrict the allowed ciphers of this policy to those defined
                    here. The default ciphers are those of the JVM platform.
                  '';

                  type = lib.types.nullOr (lib.types.listOf lib.types.str);
                };

                clientAuth = lib.mkOption {
                  default = "REQUIRE";

                  description = ''
                    The client authentication stance for this policy.
                  '';

                  type = lib.types.enum [
                    "NONE"
                    "OPTIONAL"
                    "REQUIRE"
                  ];
                };

                directoriesToCreate = lib.mkOption {
                  description = ''
                    Directories of this policy that will be created automatically
                    when the certificates directory is left at its default value.
                    This includes all options of type path that are left at their
                    default value.
                  '';

                  internal = true;
                  readOnly = true;
                  type = lib.types.listOf lib.types.path;
                };

                privateKey = lib.mkOption {
                  default = "private.key";

                  description = ''
                    The name of private PKCS #8 key file for this policy to be found
                    in the {option}`baseDirectory`, or the absolute path to
                    the key file. It is mandatory that a key can be found or generated.
                  '';

                  type = lib.types.str;
                };

                publicCertificate = lib.mkOption {
                  default = "public.crt";

                  description = ''
                    The name of public X.509 certificate (chain) file in PEM format
                    for this policy to be found in the {option}`baseDirectory`,
                    or the absolute path to the certificate file. It is mandatory
                    that a certificate can be found or generated.

                    The public certificate is required to be duplicated to the
                    directory holding trusted certificates as defined by the
                    {option}`trustedDir` option.
                  '';

                  type = lib.types.str;
                };

                revokedDir = lib.mkOption {
                  default = "${config.baseDirectory}/revoked";
                  defaultText = lib.literalExpression ''"''${config.${options.baseDirectory}}/revoked"'';

                  description = ''
                    Path to directory of CRLs (Certificate Revocation Lists) in
                    PEM format. Must be an absolute path. The existence of this
                    directory is mandatory and will need to be created manually when:
                    setting this option to something other than its default; setting
                    either this policy's {option}`baseDirectory` or
                    {option}`directories.certificates` to something other than
                    their default. Ensure read/write permissions are given to the
                    Neo4j daemon user `neo4j`.
                  '';

                  type = lib.types.path;
                };

                tlsVersions = lib.mkOption {
                  default = [ "TLSv1.2" ];

                  description = ''
                    Restrict the TLS protocol versions of this policy to those
                    defined here.
                  '';

                  type = lib.types.listOf lib.types.str;
                };

                trustAll = lib.mkOption {
                  default = false;

                  description = ''
                    Makes this policy trust all remote parties. Enabling this is not
                    recommended and the policy's trusted directory will be ignored.
                    Use of this mode is discouraged. It would offer encryption but
                    no security.
                  '';

                  type = lib.types.bool;
                };

                trustedDir = lib.mkOption {
                  default = "${config.baseDirectory}/trusted";
                  defaultText = lib.literalExpression ''"''${config.${options.baseDirectory}}/trusted"'';

                  description = ''
                    Path to directory of X.509 certificates in PEM format for
                    trusted parties. Must be an absolute path. The existence of this
                    directory is mandatory and will need to be created manually when:
                    setting this option to something other than its default; setting
                    either this policy's {option}`baseDirectory` or
                    {option}`directories.certificates` to something other than
                    their default. Ensure read/write permissions are given to the
                    Neo4j daemon user `neo4j`.

                    The public certificate as defined by
                    {option}`publicCertificate` is required to be duplicated
                    to this directory.
                  '';

                  type = lib.types.path;
                };
              };

              config.directoriesToCreate = lib.optionals (
                certDirOpt.highestPrio >= 1500 && options.baseDirectory.highestPrio >= 1500
              ) (map (opt: opt.value) (lib.filter isDefaultPathOption (lib.attrValues options)));
            }
          )
        );
    };

    workerCount = lib.mkOption {
      default = 0;

      description = ''
        Number of Neo4j worker threads, where the default of
        `0` indicates a worker count equal to the number of
        available processors.
      '';

      type = lib.types.ints.between 0 44738;
    };
  };

  ###### implementation

  config =
    let
      # Assertion helpers
      policyNameList = lib.attrNames cfg.ssl.policies;
      validPolicyNameList = [ "legacy" ] ++ policyNameList;
      validPolicyNameString = lib.concatStringsSep ", " validPolicyNameList;

      # Capture various directories left at their default so they can be created.
      defaultDirectoriesToCreate = map (opt: opt.value) (
        lib.filter isDefaultPathOption (lib.attrValues options.services.neo4j.directories)
      );
      policyDirectoriesToCreate = lib.concatMap (pol: pol.directoriesToCreate) (
        lib.attrValues cfg.ssl.policies
      );
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = !lib.elem "legacy" policyNameList;
          message = "The policy 'legacy' is special to Neo4j, and its name is reserved.";
        }
        {
          assertion = lib.elem cfg.bolt.sslPolicy validPolicyNameList;
          message = "Invalid policy assigned: `services.neo4j.bolt.sslPolicy = \"${cfg.bolt.sslPolicy}\"`, defined policies are: ${validPolicyNameString}";
        }
        {
          assertion = lib.elem cfg.https.sslPolicy validPolicyNameList;
          message = "Invalid policy assigned: `services.neo4j.https.sslPolicy = \"${cfg.https.sslPolicy}\"`, defined policies are: ${validPolicyNameString}";
        }
      ];

      environment.systemPackages = [ cfg.package ];

      systemd.services.neo4j = {
        after = [ "network.target" ];
        description = "Neo4j Daemon";

        environment = {
          NEO4J_CONF = "${cfg.directories.home}/conf";
          NEO4J_HOME = "${cfg.directories.home}";
        };

        preStart = ''
          # Directories Setup
          #   Always ensure home exists with nested conf, logs directories.
          mkdir -m 0700 -p ${cfg.directories.home}/{conf,logs}

          #   Create other sub-directories and policy directories that have been left at their default.
          ${lib.concatMapStringsSep "\n" (dir: ''
            mkdir -m 0700 -p ${dir}
          '') (defaultDirectoriesToCreate ++ policyDirectoriesToCreate)}

          # Place the configuration where Neo4j can find it.
          ln -fs ${serverConfig} ${cfg.directories.home}/conf/neo4j.conf

          # Ensure neo4j user ownership
          chown -R neo4j ${cfg.directories.home}
        '';

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/neo4j console";
          LimitNOFILE = 40000;
          PermissionsStartOnly = true;
          User = "neo4j";
        };

        wantedBy = [ "multi-user.target" ];
      };

      users.groups.neo4j = { };

      users.users.neo4j = {
        description = "Neo4j daemon user";
        group = "neo4j";
        home = cfg.directories.home;
        isSystemUser = true;
      };
    };

  meta = {
    maintainers = [ ];
  };
}
