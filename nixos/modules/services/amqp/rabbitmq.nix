{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rabbitmq;

  config_file_content = lib.generators.toKeyValue { } cfg.configItems;
  config_file = pkgs.writeText "rabbitmq.conf" config_file_content;

  advanced_config_file = pkgs.writeText "advanced.config" cfg.config;

in
{

  imports = [
    (lib.mkRemovedOptionModule [ "services" "rabbitmq" "cookie" ] ''
      This option wrote the Erlang cookie to the store, while it should be kept secret.
      Please remove it from your NixOS configuration and deploy a cookie securely instead.
      The renamed `unsafeCookie` must ONLY be used in isolated non-production environments such as NixOS VM tests.
    '')
  ];

  ###### interface
  options = {
    services.rabbitmq = {
      config = lib.mkOption {
        default = "";

        description = ''
          Verbatim advanced configuration file contents using the Erlang syntax.
          This is also known as the {file}`advanced.config` file or the old config format.

          `configItems` is preferred whenever possible. However, nested
          data structures can only be expressed properly using the `config` option.

          The contents of this option will be merged into the `configItems`
          by RabbitMQ at runtime to form the final configuration.

          See the second table on <https://www.rabbitmq.com/configure.html#config-items>
          For the distinct formats, see <https://www.rabbitmq.com/configure.html#config-file-formats>
        '';

        type = lib.types.str;
      };

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the RabbitMQ server, an Advanced Message
          Queuing Protocol (AMQP) broker.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "rabbitmq-server" { };

      configItems = lib.mkOption {
        default = { };

        description = ''
          Configuration options in RabbitMQ's new config file format,
          which is a simple key-value format that can not express nested
          data structures. This is known as the {file}`rabbitmq.conf` file,
          although outside NixOS that filename may have Erlang syntax, particularly
          prior to RabbitMQ 3.7.0.

          If you do need to express nested data structures, you can use
          `config` option. Configuration from `config`
          will be merged into these options by RabbitMQ at runtime to
          form the final configuration.

          See <https://www.rabbitmq.com/configure.html#config-items>
          For the distinct formats, see <https://www.rabbitmq.com/configure.html#config-file-formats>
        '';

        example = lib.literalExpression ''
          {
            "auth_backends.1.authn" = "rabbit_auth_backend_ldap";
            "auth_backends.1.authz" = "rabbit_auth_backend_internal";
          }
        '';

        type = lib.types.attrsOf lib.types.str;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/rabbitmq";

        description = ''
          Data directory for rabbitmq.
        '';

        type = lib.types.path;
      };

      listenAddress = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          IP address on which RabbitMQ will listen for AMQP
          connections.  Set to the empty string to listen on all
          interfaces.  Note that RabbitMQ creates a user named
          `guest` with password
          `guest` by default, so you should delete
          this user if you intend to allow external access.

          Together with 'port' setting it's mostly an alias for
          configItems."listeners.tcp.1" and it's left for backwards
          compatibility with previous version of this module.
        '';

        example = "";
        type = lib.types.str;
      };

      managementPlugin = {
        enable = lib.mkEnableOption "the management plugin";

        port = lib.mkOption {
          default = 15672;

          description = ''
            On which port to run the management plugin
          '';

          type = lib.types.port;
        };
      };

      pluginDirs = lib.mkOption {
        default = [ ];
        description = "The list of directories containing external plugins";
        type = lib.types.listOf lib.types.path;
      };

      plugins = lib.mkOption {
        default = [ ];
        description = "The names of plugins to enable";
        type = lib.types.listOf lib.types.str;
      };

      port = lib.mkOption {
        default = 5672;

        description = ''
          Port on which RabbitMQ will listen for AMQP connections.
        '';

        type = lib.types.port;
      };

      unsafeCookie = lib.mkOption {
        default = "";

        description = ''
          Erlang cookie is a string of arbitrary length which must
          be the same for several nodes to be allowed to communicate.
          Leave empty to generate automatically.

          Setting the cookie via this option exposes the cookie to the store, which
          is not recommended for security reasons.
          Only use this option in an isolated non-production environment such as
          NixOS VM tests.
        '';

        type = lib.types.str;
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {

    # This is needed so we will have 'rabbitmqctl' in our PATH
    environment.systemPackages = [ cfg.package ];
    services.epmd.enable = true;

    services.rabbitmq.configItems = {
      "listeners.tcp.1" = lib.mkDefault "${cfg.listenAddress}:${toString cfg.port}";
    }
    // lib.optionalAttrs cfg.managementPlugin.enable {
      "management.tcp.ip" = cfg.listenAddress;
      "management.tcp.port" = toString cfg.managementPlugin.port;
    };

    services.rabbitmq.plugins = lib.optional cfg.managementPlugin.enable "rabbitmq_management";

    systemd.services.rabbitmq = {
      after = [
        "network.target"
        "epmd.socket"
      ];

      description = "RabbitMQ Server";

      environment = {
        RABBITMQ_CONFIG_FILE = config_file;

        RABBITMQ_ENABLED_PLUGINS_FILE = pkgs.writeText "enabled_plugins" ''
          [ ${lib.concatStringsSep "," cfg.plugins} ].
        '';

        RABBITMQ_LOGS = "-";
        RABBITMQ_MNESIA_BASE = "${cfg.dataDir}/mnesia";
        RABBITMQ_PLUGINS_DIR = lib.concatStringsSep ":" cfg.pluginDirs;
        SYS_PREFIX = "";
      }
      // lib.optionalAttrs (cfg.config != "") { RABBITMQ_ADVANCED_CONFIG_FILE = advanced_config_file; };

      path = [
        cfg.package
        pkgs.coreutils # mkdir/chown/chmod for preStart
      ];

      preStart = ''
        ${lib.optionalString (cfg.unsafeCookie != "") ''
          install -m 600 <(echo -n ${cfg.unsafeCookie}) ${cfg.dataDir}/.erlang.cookie
        ''}
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/sbin/rabbitmq-server";
        ExecStop = "${cfg.package}/sbin/rabbitmqctl shutdown";
        Group = "rabbitmq";
        LimitNOFILE = "100000";
        LogsDirectory = "rabbitmq";
        NotifyAccess = "all";
        Restart = "on-failure";
        RestartSec = "10";
        TimeoutStartSec = "3600";
        Type = "notify";
        UMask = "0027";
        User = "rabbitmq";
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network.target"
        "epmd.socket"
      ];
    };

    users.groups.rabbitmq.gid = config.ids.gids.rabbitmq;

    users.users.rabbitmq = {
      createHome = true;
      description = "RabbitMQ server user";
      group = "rabbitmq";
      home = "${cfg.dataDir}";
      uid = config.ids.uids.rabbitmq;
    };

  };

}
