{
  config,
  lib,
  pkgs,
  options,
  utils,
  ...
}:

with lib;

let
  cfg = config.services.gitlab;
  opt = options.services.gitlab;

  toml = pkgs.formats.toml { };
  yaml = pkgs.formats.yaml { };

  git = cfg.packages.gitaly.git;

  postgresqlPackage =
    if config.services.postgresql.enable then
      config.services.postgresql.package
    else
      pkgs.postgresql_16;

  gitlabSocket = "${cfg.statePath}/tmp/sockets/gitlab.socket";
  gitalySocket = "${cfg.statePath}/tmp/sockets/gitaly.socket";
  pathUrlQuote = url: replaceStrings [ "/" ] [ "%2F" ] url;

  gitlabVersionAtLeast = version: lib.versionAtLeast (lib.getVersion cfg.packages.gitlab) version;

  databaseConfig =
    let
      val = {
        adapter = "postgresql";
        database = cfg.databaseName;
        encoding = "utf8";
        host = cfg.databaseHost;
        pool = cfg.databasePool;
        username = cfg.databaseUsername;
      }
      // cfg.extraDatabaseConfig;
    in
    {
      production =
        (if (gitlabVersionAtLeast "15.0") then { main = val; } else val)
        // lib.optionalAttrs (gitlabVersionAtLeast "15.9") {
          ci = val // {
            database_tasks = false;
          };
        };
    };

  # We only want to create a database if we're actually going to connect to it.
  databaseActuallyCreateLocally = cfg.databaseCreateLocally && cfg.databaseHost == "";

  gitalyToml = pkgs.writeText "gitaly.toml" ''
    socket_path = "${lib.escape [ "\"" ] gitalySocket}"
    runtime_dir = "/run/gitaly"
    bin_dir = "${cfg.packages.gitaly}/bin"
    prometheus_listen_addr = "localhost:9236"

    [git]
    bin_path = "${git}/bin/git"

    [gitlab-shell]
    dir = "${cfg.packages.gitlab-shell}"

    [hooks]
    custom_hooks_dir = "${cfg.statePath}/custom_hooks"

    [gitlab]
    secret_file = "${cfg.statePath}/gitlab_shell_secret"
    url = "http+unix://${pathUrlQuote gitlabSocket}"

    [gitlab.http-settings]
    self_signed_cert = false

    ${concatStringsSep "\n" (
      attrValues (
        mapAttrs (k: v: ''
          [[storage]]
          name = "${lib.escape [ "\"" ] k}"
          path = "${lib.escape [ "\"" ] v.path}"
        '') gitlabConfig.production.repositories.storages
      )
    )}
  '';

  gitlabShellConfig = flip recursiveUpdate cfg.extraShellConfig {
    gitlab_url = "http+unix://${pathUrlQuote gitlabSocket}";
    http_settings.self_signed_cert = false;
    log_file = "${cfg.statePath}/log/gitlab-shell.log";
    repos_path = "${cfg.statePath}/repositories";
    secret_file = "${cfg.statePath}/gitlab_shell_secret";
    user = cfg.user;
  };

  redisConfig.production.url = cfg.redisUrl;

  cableYml = yaml.generate "cable.yml" {
    production = {
      adapter = "redis";
      channel_prefix = "gitlab_production";
      url = cfg.redisUrl;
    };
  };

  # Redis configuration file
  resqueYml = pkgs.writeText "resque.yml" (builtins.toJSON redisConfig);

  gitlabConfig = {
    # These are the default settings from config/gitlab.example.yml
    production = flip recursiveUpdate cfg.extraConfig {
      artifacts.enabled = true;

      backup = {
        gitaly_backup_path = "${cfg.packages.gitaly}/bin/gitaly-backup";
        keep_time = cfg.backup.keepTime;
        path = cfg.backup.path;
      }
      // (optionalAttrs (cfg.backup.uploadOptions != { }) {
        upload = cfg.backup.uploadOptions;
      });

      cron_jobs = { };
      elasticsearch.indexer_path = "${pkgs.gitlab-elasticsearch-indexer}/bin/gitlab-elasticsearch-indexer";
      extra = { };
      git.bin_path = "git";
      gitaly.client_path = "${cfg.packages.gitaly}/bin";

      gitlab = {
        default_projects_features = {
          builds = true;
          container_registry = true;
          issues = true;
          merge_requests = true;
          snippets = true;
          wiki = true;
        };

        default_theme = 2;
        email_display_name = "GitLab";
        email_enabled = true;
        email_reply_to = "noreply@localhost";
        host = cfg.host;
        https = cfg.https;
        port = cfg.port;
        user = cfg.user;
      };

      gitlab_ci.builds_path = "${cfg.statePath}/builds";
      gitlab_kas.secret_file = "${cfg.statePath}/.gitlab_kas_secret";

      gitlab_shell = {
        hooks_path = "${cfg.statePath}/shell/hooks";
        path = "${cfg.packages.gitlab-shell}";
        receive_pack = true;
        secret_file = "${cfg.statePath}/gitlab_shell_secret";
        upload_pack = true;
      };

      gravatar.enabled = true;
      ldap.enabled = false;
      lfs.enabled = true;

      monitoring = {
        ip_whitelist = [
          "127.0.0.0/8"
          "::1/128"
        ];

        sidekiq_exporter = {
          enable = true;
          address = "localhost";
          port = 3807;
        };
      };

      omniauth.enabled = false;

      pages = optionalAttrs cfg.pages.enable {
        enabled = cfg.pages.enable;
        host = cfg.pages.settings.pages-domain;
        port = 8090;
        secret_file = cfg.pages.settings.api-secret-key;
      };

      registry = lib.optionalAttrs cfg.registry.enable {
        api_url = "http://${config.services.dockerRegistry.listenAddress}:${toString config.services.dockerRegistry.port}/";
        enabled = true;
        host = cfg.registry.externalAddress;
        issuer = cfg.registry.issuer;
        key = cfg.registry.keyFile;
        port = cfg.registry.externalPort;
      };

      repositories.storages.default.gitaly_address = "unix:${gitalySocket}";
      repositories.storages.default.path = "${cfg.statePath}/repositories";
      shared.path = "${cfg.statePath}/shared";
      uploads.storage_path = cfg.statePath;
      workhorse.secret_file = "${cfg.statePath}/.gitlab_workhorse_secret";
    };
  };

  gitlabEnv =
    cfg.packages.gitlab.gitlabEnv
    // {
      # allow to use bundler version from nixpkgs
      # rather than version listed in Gemfile.lock
      BUNDLER_VERSION = pkgs.bundler.version;
      GITLAB_LOG_PATH = "${cfg.statePath}/log";
      GITLAB_PATH = "${cfg.packages.gitlab}/share/gitlab/";
      GITLAB_UPLOADS_PATH = "${cfg.statePath}/uploads";
      HOME = "${cfg.statePath}/home";
      MALLOC_ARENA_MAX = "2";
      PUMA_PATH = "${cfg.statePath}/";
      RAILS_ENV = "production";
      SCHEMA = "${cfg.statePath}/db/structure.sql";
      prometheus_multiproc_dir = "/run/gitlab";
    }
    // cfg.extraEnv;

  runtimeDeps = [
    git
  ]
  ++ (with pkgs; [
    nodejs
    gzip
    gnutar
    postgresqlPackage
    coreutils
    procps
    findutils # Needed for gitlab:cleanup:orphan_job_artifact_files
  ]);

  gitlab-rake = pkgs.stdenv.mkDerivation {
    dontBuild = true;
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${cfg.packages.gitlab.rubyEnv}/bin/rake $out/bin/gitlab-rake \
          ${concatStrings (mapAttrsToList (name: value: "--set ${name} '${value}' ") gitlabEnv)} \
          --set PATH '${lib.makeBinPath runtimeDeps}:$PATH' \
          --set RAKEOPT '-f ${cfg.packages.gitlab}/share/gitlab/Rakefile' \
          --chdir '${cfg.packages.gitlab}/share/gitlab'
    '';

    name = "gitlab-rake";
    nativeBuildInputs = [ pkgs.makeWrapper ];
  };

  gitlab-rails = pkgs.stdenv.mkDerivation {
    dontBuild = true;
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${cfg.packages.gitlab.rubyEnv}/bin/rails $out/bin/gitlab-rails \
          ${concatStrings (mapAttrsToList (name: value: "--set ${name} '${value}' ") gitlabEnv)} \
          --set PATH '${lib.makeBinPath runtimeDeps}:$PATH' \
          --chdir '${cfg.packages.gitlab}/share/gitlab'
    '';

    name = "gitlab-rails";
    nativeBuildInputs = [ pkgs.makeWrapper ];
  };

  extraGitlabRb = pkgs.writeText "extra-gitlab.rb" cfg.extraGitlabRb;

  smtpSettings = pkgs.writeText "gitlab-smtp-settings.rb" ''
    if Rails.env.production?
      Rails.application.config.action_mailer.delivery_method = :smtp

      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = {
        address: "${cfg.smtp.address}",
        port: ${toString cfg.smtp.port},
        ${optionalString (cfg.smtp.username != null) ''user_name: "${cfg.smtp.username}",''}
        ${optionalString (cfg.smtp.passwordFile != null) ''password: "@smtpPassword@",''}
        domain: "${cfg.smtp.domain}",
        ${optionalString (
          cfg.smtp.authentication != null
        ) "authentication: :${cfg.smtp.authentication},"}
        enable_starttls_auto: ${boolToString cfg.smtp.enableStartTLSAuto},
        tls: ${boolToString cfg.smtp.tls},
        ca_file: "${config.security.pki.caBundle}",
        openssl_verify_mode: '${cfg.smtp.opensslVerifyMode}'
      }
    end
  '';

in
{

  imports = [
    (mkRenamedOptionModule [ "services" "gitlab" "stateDir" ] [ "services" "gitlab" "statePath" ])
    (mkRenamedOptionModule [ "services" "gitlab" "backupPath" ] [ "services" "gitlab" "backup" "path" ])
    (mkRemovedOptionModule [ "services" "gitlab" "satelliteDir" ] "")
    (mkRemovedOptionModule [
      "services"
      "gitlab"
      "logrotate"
      "extraConfig"
    ] "Modify services.logrotate.settings.gitlab directly instead")
    (mkRemovedOptionModule [
      "services"
      "gitlab"
      "pagesExtraArgs"
    ] "Use services.gitlab.pages.settings instead")
  ];

  options = {
    services.gitlab = {
      enable = mkOption {
        default = false;

        description = ''
          Enable the gitlab service.
        '';

        type = types.bool;
      };

      backup.keepTime = mkOption {
        apply = x: x * 60 * 60;
        default = 0;

        description = ''
          How long to keep the backups around, in
          hours. `0` means “keep forever”.
        '';

        example = 48;
        type = types.int;
      };

      backup.path = mkOption {
        default = cfg.statePath + "/backup";
        defaultText = literalExpression ''config.${opt.statePath} + "/backup"'';
        description = "GitLab path for backups.";
        type = types.str;
      };

      backup.skip = mkOption {
        apply = x: if isString x then x else concatStringsSep "," x;
        default = [ ];

        description = ''
          Directories to exclude from the backup. The example excludes
          CI artifacts and LFS objects from the backups. The
          `tar` option skips the creation of a tar
          file.

          Refer to <https://docs.gitlab.com/ee/raketasks/backup_restore.html#excluding-specific-directories-from-the-backup>
          for more information.
        '';

        example = [
          "artifacts"
          "lfs"
        ];

        type =
          with types;
          let
            value = enum [
              "db"
              "uploads"
              "builds"
              "artifacts"
              "lfs"
              "registry"
              "pages"
              "repositories"
              "tar"
            ];
          in
          either value (listOf value);
      };

      backup.startAt = mkOption {
        default = [ ];

        description = ''
          The time(s) to run automatic backup of GitLab
          state. Specified in systemd's time format; see
          {manpage}`systemd.time(7)`.
        '';

        example = "03:00";
        type = with types; either str (listOf str);
      };

      backup.uploadOptions = mkOption {
        default = { };

        description = ''
          GitLab automatic upload specification. Tells GitLab to
          upload the backup to a remote location when done.

          Attributes specified here are added under
          `production -> backup -> upload` in
          {file}`config/gitlab.yml`.
        '';

        example = literalExpression ''
          {
            # Fog storage connection settings, see http://fog.io/storage/
            connection = {
              provider = "AWS";
              region = "eu-north-1";
              aws_access_key_id = "AKIAXXXXXXXXXXXXXXXX";
              aws_secret_access_key = { _secret = config.deployment.keys.aws_access_key.path; };
            };

            # The remote 'directory' to store your backups in.
            # For S3, this would be the bucket name.
            remote_directory = "my-gitlab-backups";

            # Use multipart uploads when file size reaches 100MB, see
            # http://docs.aws.amazon.com/AmazonS3/latest/dev/uploadobjusingmpu.html
            multipart_chunk_size = 104857600;

            # Turns on AWS Server-Side Encryption with Amazon S3-Managed Keys for backups, this is optional
            encryption = "AES256";

            # Specifies Amazon S3 storage class to use for backups, this is optional
            storage_class = "STANDARD";
          };
        '';

        type = types.attrs;
      };

      databaseCreateLocally = mkOption {
        default = true;

        description = ''
          Whether a database should be automatically created on the
          local host. Set this to `false` if you plan
          on provisioning a local database yourself. This has no effect
          if {option}`services.gitlab.databaseHost` is customized.
        '';

        type = types.bool;
      };

      databaseHost = mkOption {
        default = "";

        description = ''
          GitLab database hostname. An empty string means
          “use local unix socket connection”.
        '';

        type = types.str;
      };

      databaseName = mkOption {
        default = "gitlab";
        description = "GitLab database name.";
        type = types.str;
      };

      databasePasswordFile = mkOption {
        default = null;

        description = ''
          File containing the GitLab database user password.

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        type = with types; nullOr path;
      };

      databasePool = mkOption {
        default = 5;
        description = "Database connection pool size.";
        type = types.int;
      };

      databaseUsername = mkOption {
        default = "gitlab";
        description = "GitLab database user.";
        type = types.str;
      };

      extraConfig = mkOption {
        default = { };

        description = ''
          Extra options to be added under
          `production` in
          {file}`config/gitlab.yml`, as a nix attribute
          set.

          Options containing secret data should be set to an attribute
          set containing the attribute `_secret` - a
          string pointing to a file containing the value the option
          should be set to. See the example to get a better picture of
          this: in the resulting
          {file}`config/gitlab.yml` file, the
          `production.omniauth.providers[0].args.client_options.secret`
          key will be set to the contents of the
          {file}`/var/keys/gitlab_oidc_secret` file.
        '';

        example = literalExpression ''
          {
            gitlab = {
              default_projects_features = {
                builds = false;
              };
            };
            omniauth = {
              enabled = true;
              auto_sign_in_with_provider = "openid_connect";
              allow_single_sign_on = ["openid_connect"];
              block_auto_created_users = false;
              providers = [
                {
                  name = "openid_connect";
                  label = "OpenID Connect";
                  args = {
                    name = "openid_connect";
                    scope = ["openid" "profile"];
                    response_type = "code";
                    issuer = "https://keycloak.example.com/auth/realms/My%20Realm";
                    discovery = true;
                    client_auth_method = "query";
                    uid_field = "preferred_username";
                    client_options = {
                      identifier = "gitlab";
                      secret = { _secret = "/var/keys/gitlab_oidc_secret"; };
                      redirect_uri = "https://git.example.com/users/auth/openid_connect/callback";
                    };
                  };
                }
              ];
            };
          };
        '';

        type = yaml.type;
      };

      extraDatabaseConfig = mkOption {
        default = { };
        description = "Extra configuration in config/database.yml.";
        type = types.attrs;
      };

      extraEnv = mkOption {
        default = { };

        description = ''
          Additional environment variables for the GitLab environment.
        '';

        type = types.attrsOf types.str;
      };

      extraGitlabRb = mkOption {
        default = "";

        description = ''
          Extra configuration to be placed in config/extra-gitlab.rb. This can
          be used to add configuration not otherwise exposed through this module's
          options.
        '';

        example = ''
          if Rails.env.production?
            Rails.application.config.action_mailer.delivery_method = :sendmail
            ActionMailer::Base.delivery_method = :sendmail
            ActionMailer::Base.sendmail_settings = {
              location: "/run/wrappers/bin/sendmail",
              arguments: "-i -t"
            }
          end
        '';

        type = types.str;
      };

      extraShellConfig = mkOption {
        default = { };
        description = "Extra configuration to merge into shell-config.yml";
        type = types.attrs;
      };

      group = mkOption {
        default = "gitlab";
        description = "Group to run gitlab and all related services.";
        type = types.str;
      };

      host = mkOption {
        default = config.networking.hostName;
        defaultText = literalExpression "config.networking.hostName";
        description = "GitLab host name. Used e.g. for copy-paste URLs.";
        type = types.str;
      };

      https = mkOption {
        default = false;
        description = "Whether gitlab prints URLs with https as scheme.";
        type = types.bool;
      };

      initialRootEmail = mkOption {
        default = "admin@local.host";

        description = ''
          Initial email address of the root account if this is a new install.
        '';

        type = types.str;
      };

      initialRootPasswordFile = mkOption {
        default = null;

        description = ''
          File containing the initial password of the root account if
          this is a new install.

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        type = with types; nullOr path;
      };

      logrotate = {
        enable = mkOption {
          default = true;

          description = ''
            Enable rotation of log files.
          '';

          type = types.bool;
        };

        frequency = mkOption {
          default = "daily";
          description = "How often to rotate the logs.";
          type = types.str;
        };

        keep = mkOption {
          default = 30;
          description = "How many rotations to keep.";
          type = types.int;
        };
      };

      packages.gitaly = mkPackageOption pkgs "gitaly" { };

      packages.gitlab = mkPackageOption pkgs "gitlab" {
        example = "gitlab-ee";
      };

      packages.gitlab-shell = mkPackageOption pkgs "gitlab-shell" { };
      packages.gitlab-workhorse = mkPackageOption pkgs "gitlab-workhorse" { };
      packages.pages = mkPackageOption pkgs "gitlab-pages" { };
      pages.enable = mkEnableOption "the GitLab Pages service";

      pages.settings = mkOption {
        description = ''
          Configuration options to set in the GitLab Pages config
          file.

          Options containing secret data should be set to an attribute
          set containing the attribute `_secret` - a string pointing
          to a file containing the value the option should be set
          to. See the example to get a better picture of this: in the
          resulting configuration file, the `auth-client-secret` and
          `auth-secret` keys will be set to the contents of the
          {file}`/var/keys/auth-client-secret` and
          {file}`/var/keys/auth-secret` files respectively.
        '';

        example = literalExpression ''
          {
            pages-domain = "example.com";
            auth-client-id = "generated-id-xxxxxxx";
            auth-client-secret = { _secret = "/var/keys/auth-client-secret"; };
            auth-redirect-uri = "https://projects.example.com/auth";
            auth-secret = { _secret = "/var/keys/auth-secret"; };
            auth-server = "https://gitlab.example.com";
          }
        '';

        type = types.submodule {
          options = {
            api-secret-key = mkOption {
              default = "${cfg.statePath}/gitlab_pages_secret";

              description = ''
                File with secret key used to authenticate with the
                GitLab API.
              '';

              internal = true;
              type = with types; nullOr str;
            };

            artifacts-server = mkOption {
              default = "http${optionalString cfg.https "s"}://${cfg.host}/api/v4";
              defaultText = "http(s)://<services.gitlab.host>/api/v4";

              description = ''
                API URL to proxy artifact requests to.
              '';

              example = "https://gitlab.example.com/api/v4";
              type = with types; nullOr str;
            };

            gitlab-server = mkOption {
              default = "http${optionalString cfg.https "s"}://${cfg.host}";
              defaultText = "http(s)://<services.gitlab.host>";

              description = ''
                Public GitLab server URL.
              '';

              example = "https://gitlab.example.com";
              type = with types; nullOr str;
            };

            internal-gitlab-server = mkOption {
              default = null;
              defaultText = "http(s)://<services.gitlab.host>";

              description = ''
                Internal GitLab server used for API requests, useful
                if you want to send that traffic over an internal load
                balancer. By default, the value of
                `services.gitlab.pages.settings.gitlab-server` is
                used.
              '';

              example = "https://gitlab.example.internal";
              type = with types; nullOr str;
            };

            listen-http = mkOption {
              apply = x: if x == [ ] then null else lib.concatStringsSep "," x;
              default = [ ];

              description = ''
                The address(es) to listen on for HTTP requests.
              '';

              type = with types; listOf str;
            };

            listen-https = mkOption {
              apply = x: if x == [ ] then null else lib.concatStringsSep "," x;
              default = [ ];

              description = ''
                The address(es) to listen on for HTTPS requests.
              '';

              type = with types; listOf str;
            };

            listen-proxy = mkOption {
              apply = x: if x == [ ] then null else lib.concatStringsSep "," x;
              default = [ "127.0.0.1:8090" ];

              description = ''
                The address(es) to listen on for proxy requests.
              '';

              type = with types; listOf str;
            };

            pages-domain = mkOption {
              description = ''
                The domain to serve static pages on.
              '';

              example = "example.com";
              type = with types; nullOr str;
            };

            pages-root = mkOption {
              default = "${gitlabConfig.production.shared.path}/pages";
              defaultText = literalExpression ''config.${opt.extraConfig}.production.shared.path + "/pages"'';

              description = ''
                The directory where pages are stored.
              '';

              type = types.str;
            };
          };

          freeformType =
            with types;
            attrsOf (
              nullOr (oneOf [
                str
                int
                bool
                attrs
              ])
            );
        };
      };

      port = mkOption {
        default = 8080;

        description = ''
          GitLab server port for copy-paste URLs, e.g. 80 or 443 if you're
          service over https.
        '';

        type = types.port;
      };

      puma.threadsMax = mkOption {
        apply = x: toString x;
        default = 4;

        description = ''
          The maximum number of threads Puma should use per
          worker. This limits how many threads Puma will automatically
          spawn in response to requests. In contrast to workers,
          threads will never be able to run Ruby code in parallel, but
          give higher IO parallelism.

          ::: {.note}
          Each thread consumes memory and contributes to Global VM
          Lock contention, so be careful when increasing this.
          :::
        '';

        type = types.int;
      };

      puma.threadsMin = mkOption {
        apply = x: toString x;
        default = 0;

        description = ''
          The minimum number of threads Puma should use per
          worker.

          ::: {.note}
          Each thread consumes memory and contributes to Global VM
          Lock contention, so be careful when increasing this.
          :::
        '';

        type = types.int;
      };

      puma.workers = mkOption {
        apply = x: toString x;
        default = 2;

        description = ''
          The number of worker processes Puma should spawn. This
          controls the amount of parallel Ruby code can be
          executed. GitLab recommends `Number of CPU cores - 1`, but at least two.

          ::: {.note}
          Each worker consumes quite a bit of memory, so
          be careful when increasing this.
          :::
        '';

        type = types.int;
      };

      redisUrl = mkOption {
        default = "unix:/run/gitlab/redis.sock";
        description = "Redis URL for all GitLab services.";
        example = "redis://localhost:6379/";
        type = types.str;
      };

      registry = {
        enable = mkOption {
          default = false;
          description = "Enable GitLab container registry.";
          type = types.bool;
        };

        package = mkOption {
          default =
            if versionAtLeast config.system.stateVersion "23.11" then
              pkgs.gitlab-container-registry
            else
              pkgs.distribution;

          defaultText = literalExpression "pkgs.distribution";

          description = ''
            Container registry package to use.

            External container registries such as `pkgs.distribution` are not supported
            anymore since GitLab 16.0.0.
          '';

          type = types.package;
        };

        certFile = mkOption {
          description = "Path to GitLab container registry certificate.";
          type = types.path;
        };

        defaultForProjects = mkOption {
          default = cfg.registry.enable;
          defaultText = literalExpression "config.${opt.registry.enable}";
          description = "If GitLab container registry should be enabled by default for projects.";
          type = types.bool;
        };

        externalAddress = mkOption {
          default = "";
          description = "External address used to access registry from the internet";
          type = types.str;
        };

        externalPort = mkOption {
          description = "External port used to access registry from the internet";
          type = types.port;
        };

        host = mkOption {
          default = config.services.gitlab.host;
          defaultText = literalExpression "config.services.gitlab.host";
          description = "GitLab container registry host name.";
          type = types.str;
        };

        issuer = mkOption {
          default = "gitlab-issuer";
          description = "GitLab container registry issuer.";
          type = types.str;
        };

        keyFile = mkOption {
          description = "Path to GitLab container registry certificate-key.";
          type = types.path;
        };

        port = mkOption {
          default = 4567;
          description = "GitLab container registry port.";
          type = types.port;
        };

        serviceName = mkOption {
          default = "container_registry";
          description = "GitLab container registry service name.";
          type = types.str;
        };
      };

      secrets.activeRecordDeterministicKeyFile = mkOption {
        default = null;

        description = ''
          A file containing the secret used to encrypt some rails data in a deterministic way
          in the DB. This should not be the same as `services.gitlab.secrets.activeRecordPrimaryKeyFile`!

          Make sure the secret is at ideally 32 characters and all random,
          no regular words or you'll be exposed to dictionary attacks.

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        type = with types; nullOr path;
      };

      secrets.activeRecordPrimaryKeyFile = mkOption {
        default = null;

        description = ''
          A file containing the secret used to encrypt some rails data
          in the DB. This should not be the same as `services.gitlab.secrets.activeRecordDeterministicKeyFile`!

          Make sure the secret is at ideally 32 characters and all random,
          no regular words or you'll be exposed to dictionary attacks.

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        type = with types; nullOr path;
      };

      secrets.activeRecordSaltFile = mkOption {
        default = null;

        description = ''
          A file containing the salt for active record encryption in the DB.

          Make sure the secret is at ideally 32 characters and all random,
          no regular words or you'll be exposed to dictionary attacks.

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        type = with types; nullOr path;
      };

      secrets.dbFile = mkOption {
        default = null;

        description = ''
          A file containing the secret used to encrypt variables in
          the DB. If you change or lose this key you will be unable to
          access variables stored in database.

          Make sure the secret is at least 32 characters and all random,
          no regular words or you'll be exposed to dictionary attacks.

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        type = with types; nullOr path;
      };

      secrets.jwsFile = mkOption {
        default = null;

        description = ''
          A file containing the secret used to encrypt session
          keys. If you change or lose this key, users will be
          disconnected.

          Make sure the secret is an RSA private key in PEM format. You can
          generate one with

          openssl genrsa 2048

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        type = with types; nullOr path;
      };

      secrets.otpFile = mkOption {
        default = null;

        description = ''
          A file containing the secret used to encrypt secrets for OTP
          tokens. If you change or lose this key, users which have 2FA
          enabled for login won't be able to login anymore.

          Make sure the secret is at least 32 characters and all random,
          no regular words or you'll be exposed to dictionary attacks.

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        type = with types; nullOr path;
      };

      secrets.secretFile = mkOption {
        default = null;

        description = ''
          A file containing the secret used to encrypt variables in
          the DB. If you change or lose this key you will be unable to
          access variables stored in database.

          Make sure the secret is at least 32 characters and all random,
          no regular words or you'll be exposed to dictionary attacks.

          This should be a string, not a nix path, since nix paths are
          copied into the world-readable nix store.
        '';

        type = with types; nullOr path;
      };

      sidekiq.concurrency = mkOption {
        default = null;

        description = ''
          How many processor threads to use for processing sidekiq background job queues. When null, the GitLab default is used.

          See <https://docs.gitlab.com/ee/administration/sidekiq/extra_sidekiq_processes.html#manage-thread-counts-explicitly> for details.
        '';

        type = with types; nullOr int;
      };

      sidekiq.memoryKiller.enable = mkOption {
        default = true;

        description = ''
          Whether the Sidekiq MemoryKiller should be turned
          on. MemoryKiller kills Sidekiq when its memory consumption
          exceeds a certain limit.

          See <https://docs.gitlab.com/ee/administration/operations/sidekiq_memory_killer.html>
          for details.
        '';

        type = types.bool;
      };

      sidekiq.memoryKiller.graceTime = mkOption {
        apply = x: toString x;
        default = 900;

        description = ''
          The time MemoryKiller waits after noticing excessive memory
          consumption before killing Sidekiq.
        '';

        type = types.int;
      };

      sidekiq.memoryKiller.maxMemory = mkOption {
        apply = x: toString (x * 1024);
        default = 2000;

        description = ''
          The maximum amount of memory, in MiB, a Sidekiq worker is
          allowed to consume before being killed.
        '';

        type = types.int;
      };

      sidekiq.memoryKiller.shutdownWait = mkOption {
        apply = x: toString x;
        default = 30;

        description = ''
          The time allowed for all jobs to finish before Sidekiq is
          killed forcefully.
        '';

        type = types.int;
      };

      smtp = {
        enable = mkOption {
          default = false;
          description = "Enable gitlab mail delivery over SMTP.";
          type = types.bool;
        };

        address = mkOption {
          default = "localhost";
          description = "Address of the SMTP server for GitLab.";
          type = types.str;
        };

        authentication = mkOption {
          default = null;
          description = "Authentication type to use, see <http://api.rubyonrails.org/classes/ActionMailer/Base.html>";
          type = with types; nullOr str;
        };

        domain = mkOption {
          default = "localhost";
          description = "HELO domain to use for outgoing mail.";
          type = types.str;
        };

        enableStartTLSAuto = mkOption {
          default = true;
          description = "Whether to try to use StartTLS.";
          type = types.bool;
        };

        opensslVerifyMode = mkOption {
          default = "peer";
          description = "How OpenSSL checks the certificate, see <http://api.rubyonrails.org/classes/ActionMailer/Base.html>";
          type = types.str;
        };

        passwordFile = mkOption {
          default = null;

          description = ''
            File containing the password of the SMTP server for GitLab.

            This should be a string, not a nix path, since nix paths
            are copied into the world-readable nix store.
          '';

          type = types.nullOr types.path;
        };

        port = mkOption {
          default = 25;
          description = "Port of the SMTP server for GitLab.";
          type = types.port;
        };

        tls = mkOption {
          default = false;
          description = "Whether to use TLS wrapper-mode.";
          type = types.bool;
        };

        username = mkOption {
          default = null;
          description = "Username of the SMTP server for GitLab.";
          type = with types; nullOr str;
        };
      };

      statePath = mkOption {
        default = "/var/gitlab/state";

        description = ''
          GitLab state directory. Configuration, repositories and
          logs, among other things, are stored here.

          The directory will be created automatically if it doesn't
          exist already. Its parent directories must be owned by
          either `root` or the user set in
          {option}`services.gitlab.user`.
        '';

        type = types.str;
      };

      user = mkOption {
        default = "gitlab";
        description = "User to run gitlab and all related services.";
        type = types.str;
      };

      workhorse.config = mkOption {
        default = { };

        description = ''
          Configuration options to add to Workhorse's configuration
          file.

          See
          <https://gitlab.com/gitlab-org/gitlab/-/blob/master/workhorse/config.toml.example>
          and
          <https://docs.gitlab.com/ee/development/workhorse/configuration.html>
          for examples and option documentation.

          Options containing secret data should be set to an attribute
          set containing the attribute `_secret` - a string pointing
          to a file containing the value the option should be set
          to. See the example to get a better picture of this: in the
          resulting configuration file, the
          `object_storage.s3.aws_secret_access_key` key will be set to
          the contents of the {file}`/var/keys/aws_secret_access_key`
          file.
        '';

        example = literalExpression ''
          {
            object_storage.provider = "AWS";
            object_storage.s3 = {
              aws_access_key_id = "AKIAXXXXXXXXXXXXXXXX";
              aws_secret_access_key = { _secret = "/var/keys/aws_secret_access_key"; };
            };
          };
        '';

        type = toml.type;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = databaseActuallyCreateLocally -> (cfg.user == cfg.databaseUsername);
        message = ''For local automatic database provisioning (services.gitlab.databaseCreateLocally == true) with peer authentication (services.gitlab.databaseHost == "") to work services.gitlab.user and services.gitlab.databaseUsername must be identical.'';
      }
      {
        assertion = (cfg.databaseHost != "") -> (cfg.databasePasswordFile != null);
        message = "When services.gitlab.databaseHost is customized, services.gitlab.databasePasswordFile must be set!";
      }
      {
        assertion = cfg.initialRootPasswordFile != null;
        message = "services.gitlab.initialRootPasswordFile must be set!";
      }
      {
        assertion = cfg.secrets.secretFile != null;
        message = "services.gitlab.secrets.secretFile must be set!";
      }
      {
        assertion = cfg.secrets.dbFile != null;
        message = "services.gitlab.secrets.dbFile must be set!";
      }
      {
        assertion = cfg.secrets.otpFile != null;
        message = "services.gitlab.secrets.otpFile must be set!";
      }
      {
        assertion = cfg.secrets.jwsFile != null;
        message = "services.gitlab.secrets.jwsFile must be set!";
      }
      {
        assertion = cfg.secrets.activeRecordPrimaryKeyFile != null;
        message = "services.gitlab.secrets.activeRecordPrimaryKeyFile must be set!";
      }
      {
        assertion = cfg.secrets.activeRecordDeterministicKeyFile != null;
        message = "services.gitlab.secrets.activeRecordDeterministicKeyFile must be set!";
      }
      {
        assertion = cfg.secrets.activeRecordSaltFile != null;
        message = "services.gitlab.secrets.activeRecordSaltFile must be set!";
      }
      {
        assertion = versionAtLeast postgresqlPackage.version "16";
        message = "PostgreSQL >= 16 is required to run GitLab 18. Follow the instructions in the manual section for upgrading PostgreSQL here: https://nixos.org/manual/nixos/stable/index.html#module-services-postgres-upgrading";
      }
    ];

    environment.systemPackages = [
      gitlab-rake
      gitlab-rails
      cfg.packages.gitlab-shell
    ];

    # Enable Docker Registry, if GitLab-Container Registry is enabled
    services.dockerRegistry = optionalAttrs cfg.registry.enable {
      enable = true;
      package = cfg.registry.package;
      enableDelete = true; # This must be true, otherwise GitLab won't manage it correctly

      extraConfig = {
        auth.token = {
          issuer = cfg.registry.issuer;
          realm = "http${optionalString (cfg.https == true) "s"}://${cfg.host}/jwt/auth";
          rootcertbundle = cfg.registry.certFile;
          service = cfg.registry.serviceName;
        };
      };

      port = cfg.registry.port;
    };

    services.gitlab.pages.settings = {
      api-secret-key = "${cfg.statePath}/gitlab_pages_secret";
    };

    # Enable rotation of log files
    services.logrotate = {
      enable = cfg.logrotate.enable;

      settings = {
        gitlab = {
          compress = true;
          copytruncate = true;
          files = "${cfg.statePath}/log/*.log";
          frequency = cfg.logrotate.frequency;
          rotate = cfg.logrotate.keep;
          su = "${cfg.user} ${cfg.group}";
        };
      };
    };

    # Use postfix to send out mails.
    services.postfix.enable = mkDefault (cfg.smtp.enable && cfg.smtp.address == "localhost");

    # We use postgres as the main data store.
    services.postgresql = optionalAttrs databaseActuallyCreateLocally {
      enable = true;
      ensureUsers = singleton { name = cfg.databaseUsername; };
    };

    # Redis is required for the sidekiq queue runner.
    services.redis.servers.gitlab = {
      enable = mkDefault true;
      unixSocket = mkDefault "/run/gitlab/redis.sock";
      unixSocketPerm = mkDefault 770;
      user = mkDefault cfg.user;
    };

    # Ensure Docker Registry launches after the certificate generation job
    systemd.services.docker-registry = optionalAttrs cfg.registry.enable {
      after = [ "gitlab-registry-cert.service" ];
      wants = [ "gitlab-registry-cert.service" ];
    };

    systemd.services.gitaly = {
      after = [
        "network.target"
        "gitlab-config.service"
      ];

      bindsTo = [ "gitlab-config.service" ];
      partOf = [ "gitlab.target" ];

      path = [
        git
      ]
      ++ (with pkgs; [
        openssh
        gzip
        bzip2
      ]);

      serviceConfig = {
        ExecStart = "${cfg.packages.gitaly}/bin/gitaly ${gitalyToml}";
        Group = cfg.group;
        Restart = "on-failure";
        RuntimeDirectory = "gitaly";
        Slice = "system-gitlab.slice";
        TimeoutSec = "infinity";
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = gitlabEnv.HOME;
      };

      wantedBy = [ "gitlab.target" ];
    };

    systemd.services.gitlab = {
      after = [
        "gitlab-workhorse.service"
        "network.target"
        "redis-gitlab.service"
        "gitlab-config.service"
        "gitlab-db-config.service"
      ];

      bindsTo = [
        "gitlab-config.service"
        "gitlab-db-config.service"
      ];

      environment = gitlabEnv;
      partOf = [ "gitlab.target" ];

      path = [
        git
      ]
      ++ (with pkgs; [
        postgresqlPackage
        openssh
        nodejs
        procps
        gnupg
        gzip
      ]);

      requiredBy = [ "gitlab.target" ];

      serviceConfig = {
        ExecStart = concatStringsSep " " [
          "${cfg.packages.gitlab.rubyEnv}/bin/bundle"
          "exec"
          "puma"
          "-e production"
          "-C ${cfg.statePath}/config/puma.rb"
          "-w ${cfg.puma.workers}"
          "-t ${cfg.puma.threadsMin}:${cfg.puma.threadsMax}"
        ];

        Group = cfg.group;
        Restart = "on-failure";
        Slice = "system-gitlab.slice";
        TimeoutSec = "infinity";
        Type = "notify";
        User = cfg.user;
        WorkingDirectory = "${cfg.packages.gitlab}/share/gitlab";
      };

      wants = [ "redis-gitlab.service" ] ++ optional (cfg.databaseHost == "") "postgresql.target";

    };

    systemd.services.gitlab-backup = {
      after = [ "gitlab.service" ];
      bindsTo = [ "gitlab.service" ];

      environment = {
        CRON = "1";
        RAILS_ENV = "production";
      }
      // optionalAttrs (stringLength cfg.backup.skip > 0) {
        SKIP = cfg.backup.skip;
      };

      serviceConfig = {
        ExecStart = "${gitlab-rake}/bin/gitlab-rake gitlab:backup:create";
        Group = cfg.group;
        Slice = "system-gitlab.slice";
        User = cfg.user;
      };

      startAt = cfg.backup.startAt;
    };

    systemd.services.gitlab-config = {
      partOf = [ "gitlab.target" ];

      path = [
        git
      ]
      ++ (with pkgs; [
        jq
        openssl
        replace-secret
      ]);

      serviceConfig = {
        ExecStart = pkgs.writeShellScript "gitlab-config" ''
          set -o errexit -o pipefail -o nounset
          shopt -s inherit_errexit

          umask u=rwx,g=rx,o=

          cp -f ${cfg.packages.gitlab}/share/gitlab/VERSION ${cfg.statePath}/VERSION
          rm -rf ${cfg.statePath}/db/*
          rm -f ${cfg.statePath}/lib
          find '${cfg.statePath}/config/' -maxdepth 1 -mindepth 1 -type d -execdir rm -rf {} \;
          cp -rf --no-preserve=mode ${cfg.packages.gitlab}/share/gitlab/config.dist/* ${cfg.statePath}/config
          cp -rf --no-preserve=mode ${cfg.packages.gitlab}/share/gitlab/db/* ${cfg.statePath}/db
          ln -sf ${extraGitlabRb} ${cfg.statePath}/config/initializers/extra-gitlab.rb
          ln -sf ${cableYml} ${cfg.statePath}/config/cable.yml
          ln -sf ${resqueYml} ${cfg.statePath}/config/resque.yml

          ${cfg.packages.gitlab-shell}/support/make_necessary_dirs

          ${optionalString cfg.smtp.enable ''
            install -m u=rw ${smtpSettings} ${cfg.statePath}/config/initializers/smtp_settings.rb
            ${optionalString (cfg.smtp.passwordFile != null) ''
              replace-secret '@smtpPassword@' '${cfg.smtp.passwordFile}' '${cfg.statePath}/config/initializers/smtp_settings.rb'
            ''}
          ''}

          (
            umask u=rwx,g=,o=

            openssl rand -hex 32 > ${cfg.statePath}/gitlab_shell_secret
            ${optionalString cfg.pages.enable ''
              openssl rand -base64 32 > ${cfg.pages.settings.api-secret-key}
            ''}

            rm -f '${cfg.statePath}/config/database.yml'

            ${lib.optionalString (cfg.databasePasswordFile != null) ''
              db_password="$(<'${cfg.databasePasswordFile}')"
              export db_password

              if [[ -z "$db_password" ]]; then
                >&2 echo "Database password was an empty string!"
                exit 1
              fi
            ''}

            # GitLab expects the `production.main` section to be the first entry in the file.
            jq <${pkgs.writeText "database.yml" (builtins.toJSON databaseConfig)} '{
              production: [
                ${
                  lib.optionalString (cfg.databasePasswordFile != null) (
                    builtins.concatStringsSep "\n      " (
                      [
                        ".production${lib.optionalString (gitlabVersionAtLeast "15.0") ".main"}.password = $ENV.db_password"
                      ]
                      ++ lib.optional (gitlabVersionAtLeast "15.9") "| .production.ci.password = $ENV.db_password"
                      ++ [ "|" ]
                    )
                  )
                } .production
                | to_entries[]
              ]
              | sort_by(.key)
              | reverse
              | from_entries
            }' >'${cfg.statePath}/config/database.yml'

            ${utils.genJqSecretsReplacementSnippet gitlabConfig "${cfg.statePath}/config/gitlab.yml"}

            rm -f '${cfg.statePath}/config/secrets.yml'

            secret="$(<'${cfg.secrets.secretFile}')"
            db="$(<'${cfg.secrets.dbFile}')"
            otp="$(<'${cfg.secrets.otpFile}')"
            jws="$(<'${cfg.secrets.jwsFile}')"
            arprimary="$(<'${cfg.secrets.activeRecordPrimaryKeyFile}')"
            ardeterministic="$(<'${cfg.secrets.activeRecordDeterministicKeyFile}')"
            arsalt="$(<'${cfg.secrets.activeRecordSaltFile}')"
            export secret db otp jws arprimary ardeterministic arsalt
            jq -n '{production: {secret_key_base: $ENV.secret,
                    otp_key_base: $ENV.otp,
                    db_key_base: $ENV.db,
                    openid_connect_signing_key: $ENV.jws,
                    active_record_encryption_primary_key: $ENV.arprimary,
                    active_record_encryption_deterministic_key: $ENV.ardeterministic,
                    active_record_encryption_key_derivation_salt: $ENV.arsalt}}' \
               > '${cfg.statePath}/config/secrets.yml'
          )

          # We remove potentially broken links to old gitlab-shell versions
          rm -Rf ${cfg.statePath}/repositories/**/*.git/hooks

          git config --global core.autocrlf "input"
        '';

        ExecStartPre =
          let
            preStartFullPrivileges = ''
              set -o errexit -o pipefail -o nounset
              shopt -s dotglob nullglob inherit_errexit

              chown --no-dereference '${cfg.user}':'${cfg.group}' '${cfg.statePath}'/*
              if [[ -n "$(ls -A '${cfg.statePath}'/config/)" ]]; then
                chown --no-dereference '${cfg.user}':'${cfg.group}' '${cfg.statePath}'/config/*
              fi
            '';
          in
          "+${pkgs.writeShellScript "gitlab-pre-start-full-privileges" preStartFullPrivileges}";

        Group = cfg.group;
        RemainAfterExit = true;
        Restart = "on-failure";
        Slice = "system-gitlab.slice";
        TimeoutSec = "infinity";
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = "${cfg.packages.gitlab}/share/gitlab";
      };

      wantedBy = [ "gitlab.target" ];
    };

    systemd.services.gitlab-db-config = {
      after = [
        "gitlab-config.service"
        "gitlab-postgresql.target"
        "postgresql.target"
      ];

      bindsTo = [ "gitlab-config.service" ];
      partOf = [ "gitlab.target" ];

      serviceConfig = {
        ExecStart = pkgs.writeShellScript "gitlab-db-config" ''
          set -o errexit -o pipefail -o nounset
          shopt -s inherit_errexit
          umask u=rwx,g=rx,o=

          initial_root_password="$(<'${cfg.initialRootPasswordFile}')"
          ${gitlab-rake}/bin/gitlab-rake gitlab:db:configure GITLAB_ROOT_PASSWORD="$initial_root_password" \
                                                             GITLAB_ROOT_EMAIL='${cfg.initialRootEmail}' > /dev/null
        '';

        Group = cfg.group;
        RemainAfterExit = true;
        Restart = "on-failure";
        Slice = "system-gitlab.slice";
        TimeoutSec = "infinity";
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = "${cfg.packages.gitlab}/share/gitlab";
      };

      wantedBy = [ "gitlab.target" ];

      wants =
        optional (cfg.databaseHost == "") "postgresql.target"
        ++ optional databaseActuallyCreateLocally "gitlab-postgresql.target";
    };

    systemd.services.gitlab-mailroom = mkIf (gitlabConfig.production.incoming_email.enabled or false) {
      after = [
        "network.target"
        "redis-gitlab.service"
        "gitlab-config.service"
      ];

      bindsTo = [ "gitlab-config.service" ];
      description = "GitLab incoming mail daemon";
      environment = gitlabEnv;
      partOf = [ "gitlab.target" ];

      serviceConfig = {
        ExecStart = "${cfg.packages.gitlab.rubyEnv}/bin/bundle exec mail_room -c ${cfg.statePath}/config/mail_room.yml";
        Group = cfg.group;
        Restart = "on-failure";
        Slice = "system-gitlab.slice";
        TimeoutSec = "infinity";
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = gitlabEnv.HOME;
      };

      wantedBy = [ "gitlab.target" ];
    };

    systemd.services.gitlab-pages =
      let
        filteredConfig = filterAttrs (_: v: v != null) cfg.pages.settings;
        isSecret = v: isAttrs v && v ? _secret && isString v._secret;
        mkPagesKeyValue = lib.generators.toKeyValue {
          mkKeyValue = lib.flip lib.generators.mkKeyValueDefault "=" {
            mkValueString =
              v:
              if isInt v then
                toString v
              else if isString v then
                v
              else if true == v then
                "true"
              else if false == v then
                "false"
              else if isSecret v then
                builtins.hashString "sha256" v._secret
              else
                throw "unsupported type ${builtins.typeOf v}: ${(lib.generators.toPretty { }) v}";
          };
        };
        secretPaths = lib.catAttrs "_secret" (lib.collect isSecret filteredConfig);
        mkSecretReplacement = file: ''
          replace-secret ${
            lib.escapeShellArgs [
              (builtins.hashString "sha256" file)
              file
              "/run/gitlab-pages/gitlab-pages.conf"
            ]
          }
        '';
        secretReplacements = lib.concatMapStrings mkSecretReplacement secretPaths;
        configFile = pkgs.writeText "gitlab-pages.conf" (mkPagesKeyValue filteredConfig);
      in
      mkIf cfg.pages.enable {
        after = [
          "network.target"
          "gitlab-config.service"
          "gitlab.service"
        ];

        bindsTo = [
          "gitlab-config.service"
          "gitlab.service"
        ];

        description = "GitLab static pages daemon";
        partOf = [ "gitlab.target" ];

        path = with pkgs; [
          unzip
          replace-secret
        ];

        serviceConfig = {
          ExecStart = "${cfg.packages.pages}/bin/gitlab-pages -config=/run/gitlab-pages/gitlab-pages.conf";

          ExecStartPre = pkgs.writeShellScript "gitlab-pages-pre-start" ''
            set -o errexit -o pipefail -o nounset
            shopt -s dotglob nullglob inherit_errexit

            install -m u=rw ${configFile} /run/gitlab-pages/gitlab-pages.conf
            ${secretReplacements}
          '';

          Group = cfg.group;
          Restart = "on-failure";
          RuntimeDirectory = "gitlab-pages";
          RuntimeDirectoryMode = "0700";
          Slice = "system-gitlab.slice";
          TimeoutSec = "infinity";
          Type = "simple";
          User = cfg.user;
          WorkingDirectory = gitlabEnv.HOME;
        };

        wantedBy = [ "gitlab.target" ];
      };

    # The postgresql module doesn't currently support concepts like
    # objects owners and extensions; for now we tack on what's needed
    # here.
    systemd.services.gitlab-postgresql =
      let
        pgsql = config.services.postgresql;
      in
      mkIf databaseActuallyCreateLocally {
        after = [ "postgresql.target" ];
        bindsTo = [ "postgresql.target" ];
        partOf = [ "gitlab.target" ];

        path = [
          pgsql.package
          pkgs.util-linux
        ];

        script = ''
          set -eu

          PSQL() {
              psql --port=${toString pgsql.settings.port} "$@"
          }

          PSQL -tAc "SELECT 1 FROM pg_database WHERE datname = '${cfg.databaseName}'" | grep -q 1 || PSQL -tAc 'CREATE DATABASE "${cfg.databaseName}" OWNER "${cfg.databaseUsername}"'
          current_owner=$(PSQL -tAc "SELECT pg_catalog.pg_get_userbyid(datdba) FROM pg_catalog.pg_database WHERE datname = '${cfg.databaseName}'")
          if [[ "$current_owner" != "${cfg.databaseUsername}" ]]; then
              PSQL -tAc 'ALTER DATABASE "${cfg.databaseName}" OWNER TO "${cfg.databaseUsername}"'
              if [[ -e "${config.services.postgresql.dataDir}/.reassigning_${cfg.databaseName}" ]]; then
                  echo "Reassigning ownership of database ${cfg.databaseName} to user ${cfg.databaseUsername} failed on last boot. Failing..."
                  exit 1
              fi
              touch "${config.services.postgresql.dataDir}/.reassigning_${cfg.databaseName}"
              PSQL "${cfg.databaseName}" -tAc "REASSIGN OWNED BY \"$current_owner\" TO \"${cfg.databaseUsername}\""
              rm "${config.services.postgresql.dataDir}/.reassigning_${cfg.databaseName}"
          fi
          PSQL '${cfg.databaseName}' -tAc "CREATE EXTENSION IF NOT EXISTS pg_trgm"
          PSQL '${cfg.databaseName}' -tAc "CREATE EXTENSION IF NOT EXISTS btree_gist;"
        '';

        serviceConfig = {
          RemainAfterExit = true;
          Slice = "system-gitlab.slice";
          Type = "oneshot";
          User = pgsql.superUser;
        };

        wantedBy = [ "gitlab.target" ];
      };

    systemd.services.gitlab-registry-cert = optionalAttrs cfg.registry.enable {
      path = with pkgs; [ openssl ];

      script = ''
        mkdir -p $(dirname ${cfg.registry.keyFile})
        mkdir -p $(dirname ${cfg.registry.certFile})
        openssl req -nodes -newkey rsa:4096 -keyout ${cfg.registry.keyFile} -out /tmp/registry-auth.csr -subj "/CN=${cfg.registry.issuer}"
        openssl x509 -in /tmp/registry-auth.csr -out ${cfg.registry.certFile} -req -signkey ${cfg.registry.keyFile} -days 3650
        chown ${cfg.user}:${cfg.group} $(dirname ${cfg.registry.keyFile})
        chown ${cfg.user}:${cfg.group} $(dirname ${cfg.registry.certFile})
        chown ${cfg.user}:${cfg.group} ${cfg.registry.keyFile}
        chown ${cfg.user}:${cfg.group} ${cfg.registry.certFile}
      '';

      serviceConfig = {
        Slice = "system-gitlab.slice";
        Type = "oneshot";
      };

      unitConfig = {
        ConditionPathExists = "!${cfg.registry.certFile}";
      };
    };

    systemd.services.gitlab-sidekiq = {
      after = [
        "network.target"
        "redis-gitlab.service"
        "postgresql.target"
        "gitlab-config.service"
        "gitlab-db-config.service"
      ];

      bindsTo = [
        "gitlab-config.service"
        "gitlab-db-config.service"
      ];

      environment =
        gitlabEnv
        // (optionalAttrs cfg.sidekiq.memoryKiller.enable {
          SIDEKIQ_MEMORY_KILLER_GRACE_TIME = cfg.sidekiq.memoryKiller.graceTime;
          SIDEKIQ_MEMORY_KILLER_MAX_RSS = cfg.sidekiq.memoryKiller.maxMemory;
          SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT = cfg.sidekiq.memoryKiller.shutdownWait;
        });

      partOf = [ "gitlab.target" ];

      path = [
        git
      ]
      ++ (with pkgs; [
        postgresqlPackage
        ruby
        openssh
        nodejs
        gnupg

        # We currently use the bundled sidekiq, if we use upstream sidekiq again, this needs to include the version
        "${cfg.packages.gitlab}/share/gitlab/vendor/gems/sidekiq"

        # Needed for GitLab project imports
        gnutar
        gzip

        procps # Sidekiq MemoryKiller
      ]);

      serviceConfig = {
        ExecStart = utils.escapeSystemdExecArgs (
          [
            "${cfg.packages.gitlab}/share/gitlab/bin/sidekiq-cluster"
            "*" # all queue groups
          ]
          ++ lib.optionals (cfg.sidekiq.concurrency != null) [
            "--concurrency"
            (toString cfg.sidekiq.concurrency)
          ]
          ++ [
            "--environment"
            "production"
            "--require"
            "."
          ]
        );

        Group = cfg.group;
        Restart = "always";
        Slice = "system-gitlab.slice";
        TimeoutSec = "infinity";
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = "${cfg.packages.gitlab}/share/gitlab";
      };

      wantedBy = [ "gitlab.target" ];
      wants = [ "redis-gitlab.service" ] ++ optional (cfg.databaseHost == "") "postgresql.target";
    };

    systemd.services.gitlab-workhorse = {
      after = [ "network.target" ];
      partOf = [ "gitlab.target" ];

      path = [
        git
      ]
      ++ (with pkgs; [
        remarshal
        exiftool
        git
        gnutar
        gzip
        openssh
        cfg.packages.gitlab-workhorse
      ]);

      serviceConfig = {
        ExecStart =
          "${cfg.packages.gitlab-workhorse}/bin/${optionalString (lib.versionAtLeast (lib.getVersion cfg.packages.gitlab-workhorse) "16.10") "gitlab-"}workhorse "
          + "-listenUmask 0 "
          + "-listenNetwork unix "
          + "-listenAddr /run/gitlab/gitlab-workhorse.socket "
          + "-authSocket ${gitlabSocket} "
          + "-documentRoot ${cfg.packages.gitlab}/share/gitlab/public "
          + "-config ${cfg.statePath}/config/gitlab-workhorse.toml "
          + "-secretPath ${cfg.statePath}/.gitlab_workhorse_secret";

        ExecStartPre = pkgs.writeShellScript "gitlab-workhorse-pre-start" ''
          set -o errexit -o pipefail -o nounset
          shopt -s dotglob nullglob inherit_errexit

          ${utils.genJqSecretsReplacementSnippet cfg.workhorse.config "${cfg.statePath}/config/gitlab-workhorse.json"}

          json2toml "${cfg.statePath}/config/gitlab-workhorse.json" "${cfg.statePath}/config/gitlab-workhorse.toml"
          rm "${cfg.statePath}/config/gitlab-workhorse.json"
        '';

        Group = cfg.group;
        Restart = "on-failure";
        Slice = "system-gitlab.slice";
        TimeoutSec = "infinity";
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = gitlabEnv.HOME;
      };

      wantedBy = [ "gitlab.target" ];
    };

    systemd.slices.system-gitlab = {
      description = "GitLab DevOps Platform Slice";
      documentation = [ "https://docs.gitlab.com/" ];
    };

    systemd.targets.gitlab = {
      description = "Common target for all GitLab services.";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d /run/gitlab 0755 ${cfg.user} ${cfg.group} -"
      "d ${gitlabEnv.HOME} 0750 ${cfg.user} ${cfg.group} -"
      "z ${gitlabEnv.HOME}/.ssh/authorized_keys 0600 ${cfg.user} ${cfg.group} -"
      "d ${cfg.backup.path} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/builds 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/config 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/db 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/log 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/repositories 2770 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/shell 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/tmp 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/tmp/pids 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/tmp/sockets 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/uploads 0700 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/custom_hooks 0700 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/custom_hooks/pre-receive.d 0700 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/custom_hooks/post-receive.d 0700 ${cfg.user} ${cfg.group} -"
      "d ${cfg.statePath}/custom_hooks/update.d 0700 ${cfg.user} ${cfg.group} -"
      "d ${gitlabConfig.production.shared.path} 0750 ${cfg.user} ${cfg.group} -"
      "d ${gitlabConfig.production.shared.path}/artifacts 0750 ${cfg.user} ${cfg.group} -"
      "d ${gitlabConfig.production.shared.path}/lfs-objects 0750 ${cfg.user} ${cfg.group} -"
      "d ${gitlabConfig.production.shared.path}/packages 0750 ${cfg.user} ${cfg.group} -"
      "d ${gitlabConfig.production.shared.path}/pages 0750 ${cfg.user} ${cfg.group} -"
      "d ${gitlabConfig.production.shared.path}/registry 0750 ${cfg.user} ${cfg.group} -"
      "d ${gitlabConfig.production.shared.path}/terraform_state 0750 ${cfg.user} ${cfg.group} -"
      "d ${gitlabConfig.production.shared.path}/ci_secure_files 0750 ${cfg.user} ${cfg.group} -"
      "d ${gitlabConfig.production.shared.path}/external-diffs 0750 ${cfg.user} ${cfg.group} -"
      "L+ /run/gitlab/config - - - - ${cfg.statePath}/config"
      "L+ /run/gitlab/log - - - - ${cfg.statePath}/log"
      "L+ /run/gitlab/tmp - - - - ${cfg.statePath}/tmp"
      "L+ /run/gitlab/uploads - - - - ${cfg.statePath}/uploads"

      "L+ /run/gitlab/shell-config.yml - - - - ${pkgs.writeText "config.yml" (builtins.toJSON gitlabShellConfig)}"
    ];

    users.groups.${cfg.group}.gid = config.ids.gids.gitlab;

    users.users.${cfg.user} = {
      group = cfg.group;
      home = "${cfg.statePath}/home";
      shell = "${pkgs.bash}/bin/bash";
      uid = config.ids.uids.gitlab;
    };

    warnings = [
      (mkIf
        (
          cfg.registry.enable
          && versionAtLeast (getVersion cfg.packages.gitlab) "16.0.0"
          && cfg.registry.package == pkgs.distribution
        )
        ''
          Support for container registries other than gitlab-container-registry has ended since GitLab 16.0.0 and is scheduled for removal in a future release.
          Please back up your data and migrate to the gitlab-container-registry package.''
      )
      (mkIf
        (
          versionAtLeast (getVersion cfg.packages.gitlab) "16.2.0"
          && versionOlder (getVersion cfg.packages.gitlab) "16.5.0"
        )
        ''
          GitLab instances created or updated between versions [15.11.0, 15.11.2] have an incorrect database schema.
          Check the upstream documentation for a workaround: https://docs.gitlab.com/ee/update/versions/gitlab_16_changes.html#undefined-column-error-upgrading-to-162-or-later''
      )
    ];

  };

  meta.doc = ./gitlab.md;
  meta.teams = [ teams.gitlab ];
}
