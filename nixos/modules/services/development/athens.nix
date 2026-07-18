{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.athens;

  athensConfig = lib.flip lib.recursiveUpdate cfg.extraConfig {
    BasicAuthPass = cfg.basicAuthPass;
    BasicAuthUser = cfg.basicAuthUser;
    CloudRuntime = cfg.cloudRuntime;
    DownloadMode = cfg.downloadMode;
    DownloadURL = cfg.downloadURL;
    EnablePprof = cfg.enablePprof;
    FilterFile = cfg.filterFile;
    ForceSSL = cfg.forceSSL;
    GithubToken = cfg.githubToken;
    GlobalEndpoint = cfg.globalEndpoint;
    GoBinary = "${cfg.goBinary}/bin/go";
    GoBinaryEnvVars = lib.mapAttrsToList (k: v: "${k}=${v}") cfg.goBinaryEnvVars;
    GoEnv = cfg.goEnv;
    GoGetDir = cfg.goGetDir;
    GoGetWorkers = cfg.goGetWorkers;
    HGRCPath = cfg.hgrcPath;

    Index = {
      MySQL = {
        Database = cfg.index.mysql.database;
        Host = cfg.index.mysql.host;

        Params = {
          parseTime = cfg.index.mysql.params.parseTime;
          timeout = cfg.index.mysql.params.timeout;
        };

        Password = cfg.index.mysql.password;
        Port = cfg.index.mysql.port;
        Protocol = cfg.index.mysql.protocol;
        User = cfg.index.mysql.user;
      };

      Postgres = {
        Database = cfg.index.postgres.database;
        Host = cfg.index.postgres.host;

        Params = {
          connect_timeout = cfg.index.postgres.params.connect_timeout;
          sslmode = cfg.index.postgres.params.sslmode;
        };

        Password = cfg.index.postgres.password;
        Port = cfg.index.postgres.port;
        User = cfg.index.postgres.user;
      };
    };

    IndexType = cfg.indexType;
    LogLevel = cfg.logLevel;
    NETRCPath = cfg.netrcPath;
    NetworkMode = cfg.networkMode;
    NoSumPatterns = cfg.noSumPatterns;
    PathPrefix = cfg.pathPrefix;
    Port = ":${toString cfg.port}";
    PprofPort = ":${toString cfg.pprofPort}";
    ProtocolWorkers = cfg.protocolWorkers;
    RobotsFile = cfg.robotsFile;
    ShutdownTimeout = cfg.shutdownTimeout;

    SingleFlight = {
      Etcd = {
        Endpoints = builtins.concatStringsSep "," cfg.singleFlight.etcd.endpoints;
      };

      Redis = {
        Endpoint = cfg.singleFlight.redis.endpoint;

        LockConfig = {
          MaxRetries = cfg.singleFlight.redis.lockConfig.maxRetries;
          TTL = cfg.singleFlight.redis.lockConfig.ttl;
          Timeout = cfg.singleFlight.redis.lockConfig.timeout;
        };

        Password = cfg.singleFlight.redis.password;
      };

      RedisSentinel = {
        Endpoints = cfg.singleFlight.redisSentinel.endpoints;

        LockConfig = {
          MaxRetries = cfg.singleFlight.redisSentinel.lockConfig.maxRetries;
          TTL = cfg.singleFlight.redisSentinel.lockConfig.ttl;
          Timeout = cfg.singleFlight.redisSentinel.lockConfig.timeout;
        };

        MasterName = cfg.singleFlight.redisSentinel.masterName;
        SentinelPassword = cfg.singleFlight.redisSentinel.sentinelPassword;
      };
    };

    SingleFlightType = cfg.singleFlightType;
    StatsExporter = cfg.statsExporter;

    Storage = {
      AzureBlob = {
        AccountKey = cfg.storage.azureblob.accountKey;
        AccountName = cfg.storage.azureblob.accountName;
        ContainerName = cfg.storage.azureblob.containerName;
      };

      CDN = {
        Endpoint = cfg.storage.cdn.endpoint;
      };

      Disk = {
        RootPath = cfg.storage.disk.rootPath;
      };

      External = {
        URL = cfg.storage.external.url;
      };

      GCP = {
        Bucket = cfg.storage.gcp.bucket;
        JSONKey = cfg.storage.gcp.jsonKey;
        ProjectID = cfg.storage.gcp.projectID;
      };

      Mongo = {
        CertPath = cfg.storage.mongo.certPath;
        DefaultDBName = cfg.storage.mongo.defaultDBName;
        Insecure = cfg.storage.mongo.insecure;
        URL = cfg.storage.mongo.url;
      };

      S3 = {
        AwsContainerCredentialsRelativeURI = cfg.storage.s3.awsContainerCredentialsRelativeURI;
        Bucket = cfg.storage.s3.bucket;
        CredentialsEndpoint = cfg.storage.s3.credentialsEndpoint;
        Endpoint = cfg.storage.s3.endpoint;
        ForcePathStyle = cfg.storage.s3.forcePathStyle;
        Key = cfg.storage.s3.key;
        Region = cfg.storage.s3.region;
        Secret = cfg.storage.s3.secret;
        Token = cfg.storage.s3.token;
        UseDefaultConfiguration = cfg.storage.s3.useDefaultConfiguration;
      };
    };

    StorageType = cfg.storageType;
    SumDBs = cfg.sumDBs;
    TLSCertFile = cfg.tlsCertFile;
    TLSKeyFile = cfg.tlsKeyFile;
    Timeout = cfg.timeout;
    TraceExporter = cfg.traceExporter;
    UnixSocket = cfg.unixSocket;
    ValidatorHook = cfg.validatorHook;
  };

  configFile = lib.pipe athensConfig [
    (lib.filterAttrsRecursive (_k: v: v != null))
    ((pkgs.formats.toml { }).generate "config.toml")
  ];
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "athens"
      "storage"
      "minio"
    ] "Support for Minio storage backend has been removed, as minio is unmaintained.")
  ];

  options.services.athens = {
    enable = lib.mkEnableOption "Go module datastore and proxy";

    package = lib.mkOption {
      default = pkgs.athens;
      defaultText = lib.literalExpression "pkgs.athens";
      description = "Which athens derivation to use";
      example = "pkgs.athens";
      type = lib.types.package;
    };

    basicAuthPass = lib.mkOption {
      default = null;

      description = ''
        Password for basic auth. Warning: this is stored in plain text in the config file.
      '';

      example = "swordfish";
      type = lib.types.nullOr lib.types.str;
    };

    basicAuthUser = lib.mkOption {
      default = null;

      description = ''
        Username for basic auth.
      '';

      example = "user";
      type = lib.types.nullOr lib.types.str;
    };

    cloudRuntime = lib.mkOption {
      default = "none";

      description = ''
        Specifies the Cloud Provider on which the Proxy/registry is running.
      '';

      example = "GCP";

      type = lib.types.enum [
        "GCP"
        "none"
      ];
    };

    downloadMode = lib.mkOption {
      default = "async_redirect";

      description = ''
        Defines how Athens behaves when a module@version
        is not found in storage. There are 7 options:
        1. "sync": download the module synchronously and
        return the results to the client.
        2. "async": return 404, but asynchronously store the module
        in the storage backend.
        3. "redirect": return a 301 redirect status to the client
        with the base URL as the DownloadRedirectURL from below.
        4. "async_redirect": same as option number 3 but it will
        asynchronously store the module to the backend.
        5. "none": return 404 if a module is not found and do nothing.
        6. "file:<path>": will point to an HCL file that specifies
        any of the 5 options above based on different import paths.
        7. "custom:<base64-encoded-hcl>" is the same as option 6
        but the file is fully encoded in the option. This is
        useful for using an environment variable in serverless
        deployments.
      '';

      type = lib.types.oneOf [
        (lib.types.enum [
          "sync"
          "async"
          "redirect"
          "async_redirect"
          "none"
        ])
        (lib.types.strMatching "^file:.*$|^custom:.*$")
      ];
    };

    downloadURL = lib.mkOption {
      default = "https://proxy.golang.org";
      description = "URL used if DownloadMode is set to redirect.";
      type = lib.types.str;
    };

    enablePprof = lib.mkOption {
      default = false;
      description = "Enable pprof endpoints.";
      type = lib.types.bool;
    };

    extraConfig = lib.mkOption {
      default = { };

      description = ''
        Extra configuration options for the athens config file.
      '';

      type = lib.types.attrs;
    };

    filterFile = lib.mkOption {
      default = null;
      description = "Filename for the include exclude filter.";

      example = lib.literalExpression ''
        pkgs.writeText "filterFile" '''
          - github.com/azure
          + github.com/azure/azure-sdk-for-go
          D golang.org/x/tools
        '''
      '';

      type = lib.types.nullOr lib.types.path;
    };

    forceSSL = lib.mkOption {
      default = false;

      description = ''
        Force SSL redirects for incoming requests.
      '';

      type = lib.types.bool;
    };

    githubToken = lib.mkOption {
      default = null;

      description = ''
        Creates .netrc file with the given token to be used for GitHub.
        Warning: this is stored in plain text in the config file.
      '';

      example = "ghp_1234567890";
      type = lib.types.nullOr lib.types.str;
    };

    globalEndpoint = lib.mkOption {
      default = "";

      description = ''
        Endpoint for a package registry in case of a proxy cache miss.
      '';

      example = "http://upstream-athens.example.com:3000";
      type = lib.types.str;
    };

    goBinary = lib.mkOption {
      default = pkgs.go;
      defaultText = lib.literalExpression "pkgs.go";

      description = ''
        The Go package used by Athens at runtime.

        Athens primarily runs two Go commands:
        1. `go mod download -json <module>@<version>`
        2. `go list -m -json <module>@latest`
      '';

      example = "pkgs.go_1_23";
      type = lib.types.package;
    };

    goBinaryEnvVars = lib.mkOption {
      default = { };
      description = "Environment variables to pass to the Go binary.";

      example = ''
        { "GOPROXY" = "direct", "GODEBUG" = "true" }
      '';

      type = lib.types.attrs;
    };

    goEnv = lib.mkOption {
      default = "development";
      description = "Specifies the type of environment to run. One of 'development' or 'production'.";
      example = "production";

      type = lib.types.enum [
        "development"
        "production"
      ];
    };

    goGetDir = lib.mkOption {
      default = null;

      description = ''
        Temporary directory that Athens will use to
        fetch modules from VCS prior to persisting
        them to a storage backend.

        If the value is empty, Athens will use the
        default OS temp directory.
      '';

      example = "/tmp/athens";
      type = lib.types.nullOr lib.types.path;
    };

    goGetWorkers = lib.mkOption {
      default = 10;
      description = "Number of workers concurrently downloading modules.";
      example = 32;
      type = lib.types.int;
    };

    hgrcPath = lib.mkOption {
      default = null;

      description = ''
        Path to the .hgrc file.
      '';

      example = "/home/user/.hgrc";
      type = lib.types.nullOr lib.types.path;
    };

    index = {
      mysql = {
        database = lib.mkOption {
          default = "athens";
          description = "Database name for the MySQL database.";
          type = lib.types.str;
        };

        host = lib.mkOption {
          default = "localhost";
          description = "Host for the MySQL database.";
          type = lib.types.str;
        };

        params = {
          parseTime = lib.mkOption {
            default = "true";
            description = "Parse time for the MySQL database.";
            type = lib.types.nullOr lib.types.str;
          };

          timeout = lib.mkOption {
            default = "30s";
            description = "Timeout for the MySQL database.";
            type = lib.types.nullOr lib.types.str;
          };
        };

        password = lib.mkOption {
          default = null;
          description = "Password for the MySQL database. Warning: this is stored in plain text in the config file.";
          type = lib.types.nullOr lib.types.str;
        };

        port = lib.mkOption {
          default = 3306;
          description = "Port for the MySQL database.";
          type = lib.types.port;
        };

        protocol = lib.mkOption {
          default = "tcp";
          description = "Protocol for the MySQL database.";
          type = lib.types.str;
        };

        user = lib.mkOption {
          default = "root";
          description = "User for the MySQL database.";
          type = lib.types.str;
        };
      };

      postgres = {
        database = lib.mkOption {
          default = "athens";
          description = "Database name for the Postgres database.";
          type = lib.types.str;
        };

        host = lib.mkOption {
          default = "localhost";
          description = "Host for the Postgres database.";
          type = lib.types.str;
        };

        params = {
          connect_timeout = lib.mkOption {
            default = "30s";
            description = "Connect timeout for the Postgres database.";
            type = lib.types.nullOr lib.types.str;
          };

          sslmode = lib.mkOption {
            default = "disable";
            description = "SSL mode for the Postgres database.";
            type = lib.types.nullOr lib.types.str;
          };
        };

        password = lib.mkOption {
          default = null;
          description = "Password for the Postgres database. Warning: this is stored in plain text in the config file.";
          type = lib.types.nullOr lib.types.str;
        };

        port = lib.mkOption {
          default = 5432;
          description = "Port for the Postgres database.";
          type = lib.types.port;
        };

        user = lib.mkOption {
          default = "postgres";
          description = "User for the Postgres database.";
          type = lib.types.str;
        };
      };
    };

    indexType = lib.mkOption {
      default = "none";

      description = ''
        Type of index backend Athens will use.
      '';

      type = lib.types.enum [
        "none"
        "memory"
        "mysql"
        "postgres"
      ];
    };

    logLevel = lib.mkOption {
      default = "warning";

      description = ''
        Log level for Athens.
        Supports all logrus log levels (https://github.com/Sirupsen/logrus#level-logging)".
      '';

      example = "debug";

      type = lib.types.nullOr (
        lib.types.enum [
          "panic"
          "fatal"
          "error"
          "warning"
          "info"
          "debug"
          "trace"
        ]
      );
    };

    netrcPath = lib.mkOption {
      default = null;

      description = ''
        Path to the .netrc file.
      '';

      example = "/home/user/.netrc";
      type = lib.types.nullOr lib.types.path;
    };

    networkMode = lib.mkOption {
      default = "strict";

      description = ''
        Configures how Athens will return the results
        of the /list endpoint as it can be assembled from both its own
        storage and the upstream VCS.

        Note, that for better error messaging, this would also affect how other
        endpoints behave.

        Modes:
        1. strict: merge VCS versions with storage versions, but fail if either of them fails.
        2. offline: only get storage versions, never reach out to VCS.
        3. fallback: only return storage versions, if VCS fails. Note this means that you may
        see inconsistent results since fallback mode does a best effort of giving you what's
        available at the time of requesting versions.
      '';

      type = lib.types.enum [
        "strict"
        "offline"
        "fallback"
      ];
    };

    noSumPatterns = lib.mkOption {
      default = [ ];

      description = ''
        List of patterns that Athens sum db proxy will return a 403 for.
      '';

      example = [ "github.com/mycompany/*" ];
      type = lib.types.listOf lib.types.str;
    };

    pathPrefix = lib.mkOption {
      default = null;

      description = ''
        Sets basepath for all routes.
      '';

      example = "/athens";
      type = lib.types.nullOr lib.types.str;
    };

    port = lib.mkOption {
      default = 3000;

      description = ''
        Port number Athens listens on.
      '';

      example = 443;
      type = lib.types.port;
    };

    pprofPort = lib.mkOption {
      default = 3301;
      description = "Port number for pprof endpoints.";
      example = 443;
      type = lib.types.port;
    };

    protocolWorkers = lib.mkOption {
      default = 30;
      description = "Number of workers concurrently serving protocol paths.";
      type = lib.types.int;
    };

    robotsFile = lib.mkOption {
      default = null;
      description = "Provides /robots.txt for net crawlers.";
      example = lib.literalExpression ''pkgs.writeText "robots.txt" "# my custom robots.txt ..."'';
      type = lib.types.nullOr lib.types.path;
    };

    shutdownTimeout = lib.mkOption {
      default = 60;

      description = ''
        Number of seconds to wait for the server to shutdown gracefully.
      '';

      example = 1;
      type = lib.types.int;
    };

    singleFlight = {
      etcd = {
        endpoints = lib.mkOption {
          default = [ ];
          description = "URLs that determine all distributed etcd servers.";
          example = [ "localhost:2379" ];
          type = lib.types.listOf lib.types.str;
        };
      };

      redis = {
        endpoint = lib.mkOption {
          default = "";
          description = "URL of the redis server.";
          example = "localhost:6379";
          type = lib.types.str;
        };

        lockConfig = {
          maxRetries = lib.mkOption {
            default = 10;
            description = "Maximum number of retries for the lock.";
            example = 1;
            type = lib.types.int;
          };

          timeout = lib.mkOption {
            default = 15;
            description = "Timeout for the lock in seconds.";
            example = 1;
            type = lib.types.int;
          };

          ttl = lib.mkOption {
            default = 900;
            description = "TTL for the lock in seconds.";
            example = 1;
            type = lib.types.int;
          };
        };

        password = lib.mkOption {
          default = "";
          description = "Password for the redis server. Warning: this is stored in plain text in the config file.";
          example = "swordfish";
          type = lib.types.str;
        };
      };

      redisSentinel = {
        endpoints = lib.mkOption {
          default = [ ];
          description = "URLs that determine all distributed redis servers.";
          example = [ "localhost:26379" ];
          type = lib.types.listOf lib.types.str;
        };

        lockConfig = {
          maxRetries = lib.mkOption {
            default = 10;
            description = "Maximum number of retries for the lock.";
            example = 1;
            type = lib.types.int;
          };

          timeout = lib.mkOption {
            default = 15;
            description = "Timeout for the lock in seconds.";
            example = 1;
            type = lib.types.int;
          };

          ttl = lib.mkOption {
            default = 900;
            description = "TTL for the lock in seconds.";
            example = 1;
            type = lib.types.int;
          };
        };

        masterName = lib.mkOption {
          default = "";
          description = "Name of the sentinel master server.";
          example = "redis-1";
          type = lib.types.str;
        };

        sentinelPassword = lib.mkOption {
          default = "";
          description = "Password for the sentinel server. Warning: this is stored in plain text in the config file.";
          example = "swordfish";
          type = lib.types.str;
        };
      };
    };

    singleFlightType = lib.mkOption {
      default = "memory";

      description = ''
        Determines what mechanism Athens uses to manage concurrency flowing into the Athens backend.
      '';

      type = lib.types.enum [
        "memory"
        "etcd"
        "redis"
        "redis-sentinel"
        "gcp"
        "azureblob"
      ];
    };

    statsExporter = lib.mkOption {
      default = null;
      description = "Stats exporter to use.";
      type = lib.types.nullOr (lib.types.enum [ "prometheus" ]);
    };

    storage = {
      azureblob = {
        accountKey = lib.mkOption {
          default = null;
          description = "Account key for the Azure Blob storage backend. Warning: this is stored in plain text in the config file.";
          type = lib.types.nullOr lib.types.str;
        };

        accountName = lib.mkOption {
          default = null;
          description = "Account name for the Azure Blob storage backend.";
          type = lib.types.nullOr lib.types.str;
        };

        containerName = lib.mkOption {
          default = null;
          description = "Container name for the Azure Blob storage backend.";
          type = lib.types.nullOr lib.types.str;
        };
      };

      cdn = {
        endpoint = lib.mkOption {
          default = null;
          description = "hostname of the CDN server.";
          example = "cdn.example.com";
          type = lib.types.nullOr lib.types.str;
        };
      };

      disk = {
        rootPath = lib.mkOption {
          default = "/var/lib/athens";
          description = "Athens disk root folder.";
          type = lib.types.nullOr lib.types.path;
        };
      };

      external = {
        url = lib.mkOption {
          default = null;
          description = "URL of the backend storage layer.";
          example = "https://athens.example.com";
          type = lib.types.nullOr lib.types.str;
        };
      };

      gcp = {
        bucket = lib.mkOption {
          default = null;
          description = "GCP backend storage bucket.";
          example = "my-bucket";
          type = lib.types.nullOr lib.types.str;
        };

        jsonKey = lib.mkOption {
          default = null;
          description = "Base64 encoded GCP service account key. Warning: this is stored in plain text in the config file.";
          type = lib.types.nullOr lib.types.str;
        };

        projectID = lib.mkOption {
          default = null;
          description = "GCP project ID.";
          example = "my-project";
          type = lib.types.nullOr lib.types.str;
        };
      };

      mongo = {
        certPath = lib.mkOption {
          default = null;
          description = "Path to the certificate file for the mongo database.";
          example = "/etc/ssl/mongo.pem";
          type = lib.types.nullOr lib.types.path;
        };

        defaultDBName = lib.mkOption {
          default = null;
          description = "Name of the mongo database.";
          example = "athens";
          type = lib.types.nullOr lib.types.str;
        };

        insecure = lib.mkOption {
          default = false;
          description = "Allow insecure connections to the mongo database.";
          type = lib.types.bool;
        };

        url = lib.mkOption {
          default = null;
          description = "URL of the mongo database.";
          example = "mongodb://localhost:27017";
          type = lib.types.nullOr lib.types.str;
        };
      };

      s3 = {
        awsContainerCredentialsRelativeURI = lib.mkOption {
          default = null;
          description = "Container relative url (used by fargate).";
          type = lib.types.nullOr lib.types.str;
        };

        bucket = lib.mkOption {
          default = null;
          description = "Bucket name for the S3 storage backend.";
          example = "gomods";
          type = lib.types.nullOr lib.types.str;
        };

        credentialsEndpoint = lib.mkOption {
          default = "";
          description = "Credentials endpoint for the S3 storage backend.";
          type = lib.types.str;
        };

        endpoint = lib.mkOption {
          default = null;
          description = "Endpoint for the S3 storage backend.";
          type = lib.types.nullOr lib.types.str;
        };

        forcePathStyle = lib.mkOption {
          default = false;
          description = "Force path style for the S3 storage backend.";
          type = lib.types.bool;
        };

        key = lib.mkOption {
          default = null;
          description = "Access key id for the S3 storage backend.";
          type = lib.types.nullOr lib.types.str;
        };

        region = lib.mkOption {
          default = null;
          description = "Region of the S3 storage backend.";
          example = "eu-west-3";
          type = lib.types.nullOr lib.types.str;
        };

        secret = lib.mkOption {
          default = "";
          description = "Secret key for the S3 storage backend. Warning: this is stored in plain text in the config file.";
          type = lib.types.str;
        };

        token = lib.mkOption {
          default = null;
          description = "Token for the S3 storage backend. Warning: this is stored in plain text in the config file.";
          type = lib.types.nullOr lib.types.str;
        };

        useDefaultConfiguration = lib.mkOption {
          default = false;
          description = "Use default configuration for the S3 storage backend.";
          type = lib.types.bool;
        };
      };
    };

    storageType = lib.mkOption {
      default = "disk";
      description = "Specifies the type of storage backend to use.";

      type = lib.types.enum [
        "memory"
        "disk"
        "mongo"
        "gcp"
        "s3"
        "azureblob"
        "external"
      ];
    };

    sumDBs = lib.mkOption {
      default = [ "https://sum.golang.org" ];

      description = ''
        List of fully qualified URLs that Athens will proxy
        that the go command can use a checksum verifier.
      '';

      type = lib.types.listOf lib.types.str;
    };

    timeout = lib.mkOption {
      default = 300;
      description = "Timeout for external network calls in seconds.";
      example = 3;
      type = lib.types.int;
    };

    tlsCertFile = lib.mkOption {
      default = null;
      description = "Path to the TLS certificate file.";
      example = "/etc/ssl/certs/athens.crt";
      type = lib.types.nullOr lib.types.path;
    };

    tlsKeyFile = lib.mkOption {
      default = null;
      description = "Path to the TLS key file.";
      example = "/etc/ssl/certs/athens.key";
      type = lib.types.nullOr lib.types.path;
    };

    traceExporter = lib.mkOption {
      default = null;

      description = ''
        Trace exporter to use.
      '';

      type = lib.types.nullOr (
        lib.types.enum [
          "jaeger"
          "datadog"
        ]
      );
    };

    traceExporterURL = lib.mkOption {
      default = null;

      description = ''
        URL endpoint that traces will be sent to.
      '';

      example = "http://localhost:14268";
      type = lib.types.nullOr lib.types.str;
    };

    unixSocket = lib.mkOption {
      default = null;

      description = ''
        Path to the unix socket file.
        If set, Athens will listen on the unix socket instead of TCP socket.
      '';

      example = "/run/athens.sock";
      type = lib.types.nullOr lib.types.path;
    };

    validatorHook = lib.mkOption {
      default = null;

      description = ''
        Endpoint to validate modules against.

        Not used if empty.
      '';

      example = "https://validation.example.com";
      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts =
        lib.optionals (cfg.unixSocket == null) [ cfg.port ]
        ++ lib.optionals cfg.enablePprof [ cfg.pprofPort ];
    };

    systemd.services.athens = {
      after = [ "network-online.target" ];
      description = "Athens Go module proxy";
      documentation = [ "https://docs.gomods.io" ];

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/athens -config_file=${configFile}";
        KillMode = "mixed";
        KillSignal = "SIGINT";
        LimitNOFILE = 1048576;
        LimitNPROC = 512;
        Nice = 5;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = "read-only";
        ProtectSystem = "full";

        ReadWritePaths = lib.mkIf (
          cfg.storage.disk.rootPath != null && (!lib.hasPrefix "/var/lib/" cfg.storage.disk.rootPath)
        ) [ cfg.storage.disk.rootPath ];

        Restart = "on-abnormal";

        StateDirectory = lib.mkIf (lib.hasPrefix "/var/lib/" cfg.storage.disk.rootPath) [
          (lib.removePrefix "/var/lib/" cfg.storage.disk.rootPath)
        ];

        TimeoutStopSec = cfg.shutdownTimeout;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    doc = ./athens.md;
    maintainers = pkgs.athens.meta.maintainers;
  };
}
