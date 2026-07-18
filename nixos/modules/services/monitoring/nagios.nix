# Nagios system/network monitoring daemon.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nagios;

  nagiosState = "/var/lib/nagios";
  nagiosLogDir = "/var/log/nagios";
  urlPath = "/nagios";

  nagiosObjectDefs = cfg.objectDefs;

  nagiosObjectDefsDir = pkgs.runCommand "nagios-objects" {
    inherit nagiosObjectDefs;
    preferLocalBuild = true;
  } "mkdir -p $out; ln -s $nagiosObjectDefs $out/";

  nagiosCfgFile =
    let
      default = {
        cfg_dir = "${nagiosObjectDefsDir}";
        check_result_path = "${nagiosState}";
        command_file = "${nagiosState}/nagios.cmd";
        illegal_macro_output_chars = "`~$&|'\"<>";
        lock_file = "/run/nagios.lock";
        log_archive_path = "${nagiosLogDir}/archive";
        log_file = "${nagiosLogDir}/current";
        nagios_group = "nagios";
        nagios_user = "nagios";
        object_cache_file = "${nagiosState}/objects.cache";
        query_socket = "${nagiosState}/nagios.qh";
        retain_state_information = "1";
        state_retention_file = "${nagiosState}/retention.dat";
        status_file = "${nagiosState}/status.dat";
        temp_file = "${nagiosState}/nagios.tmp";
      };
      lines = lib.mapAttrsToList (key: value: "${key}=${value}") (default // cfg.extraConfig);
      content = lib.concatStringsSep "\n" lines;
      file = pkgs.writeText "nagios.cfg" content;
      validated = pkgs.runCommand "nagios-checked.cfg" { preferLocalBuild = true; } ''
        cp ${file} nagios.cfg
        # nagios checks the existence of /var/lib/nagios, but
        # it does not exist in the build sandbox, so we fake it
        mkdir lib
        lib=$(readlink -f lib)
        sed -i s@=${nagiosState}@=$lib@ nagios.cfg
        ${pkgs.nagios}/bin/nagios -v nagios.cfg && cp ${file} $out
      '';
      defaultCfgFile = if cfg.validateConfig then validated else file;
    in
    if cfg.mainConfigFile == null then defaultCfgFile else cfg.mainConfigFile;

  # Plain configuration for the Nagios web-interface with no
  # authentication.
  nagiosCGICfgFile = pkgs.writeText "nagios.cgi.conf" ''
    main_config_file=${cfg.mainConfigFile}
    use_authentication=0
    url_html_path=${urlPath}
  '';

  extraHttpdConfig = ''
    ScriptAlias ${urlPath}/cgi-bin ${pkgs.nagios}/sbin

    <Directory "${pkgs.nagios}/sbin">
      Options ExecCGI
      Require all granted
      SetEnv NAGIOS_CGI_CONFIG ${cfg.cgiConfigFile}
    </Directory>

    Alias ${urlPath} ${pkgs.nagios}/share

    <Directory "${pkgs.nagios}/share">
      Options None
      Require all granted
    </Directory>
  '';

in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "nagios"
      "urlPath"
    ] "The urlPath option has been removed as it is hard coded to /nagios in the nagios package.")
  ];

  options = {
    services.nagios = {
      enable = lib.mkEnableOption "[Nagios](https://www.nagios.org/) to monitor your system or network";

      cgiConfigFile = lib.mkOption {
        default = nagiosCGICfgFile;
        defaultText = lib.literalExpression "nagiosCGICfgFile";

        description = ''
          Derivation for the configuration file of Nagios CGI scripts
          that can be used in web servers for running the Nagios web interface.
        '';

        type = lib.types.package;
      };

      enableWebInterface = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the Nagios web interface.  You should also
          enable Apache ({option}`services.httpd.enable`).
        '';

        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = { };
        description = "Configuration to add to /etc/nagios.cfg";

        example = {
          debug_file = "/var/log/nagios/debug.log";
          debug_level = "-1";
        };

        type = lib.types.attrsOf lib.types.str;
      };

      mainConfigFile = lib.mkOption {
        default = null;

        description = ''
          If non-null, overrides the main configuration file of Nagios.
        '';

        type = lib.types.nullOr lib.types.package;
      };

      objectDefs = lib.mkOption {
        description = ''
          A list of Nagios object configuration files that must define
          the hosts, host groups, services and contacts for the
          network that you want Nagios to monitor.
        '';

        example = lib.literalExpression "[ ./objects.cfg ]";
        type = lib.types.listOf lib.types.path;
      };

      plugins = lib.mkOption {
        default = with pkgs; [
          monitoring-plugins
          msmtp
          mailutils
        ];

        defaultText = lib.literalExpression "[pkgs.monitoring-plugins pkgs.msmtp pkgs.mailutils]";

        description = ''
          Packages to be added to the Nagios {env}`PATH`.
          Typically used to add plugins, but can be anything.
        '';

        type = lib.types.listOf lib.types.package;
      };

      validateConfig = lib.mkOption {
        default = pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform;
        defaultText = lib.literalExpression "pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform";
        description = "if true, the syntax of the nagios configuration file is checked at build time";
        type = lib.types.bool;
      };

      virtualHost = lib.mkOption {
        description = ''
          Apache configuration can be done by adapting {option}`services.httpd.virtualHosts`.
          See [](#opt-services.httpd.virtualHosts) for further information.
        '';

        example = lib.literalExpression ''
          { hostName = "example.org";
            adminAddr = "webmaster@example.org";
            enableSSL = true;
            sslServerCert = "/var/lib/acme/example.org/full.pem";
            sslServerKey = "/var/lib/acme/example.org/key.pem";
          }
        '';

        type = lib.types.submodule (import ../web-servers/apache-httpd/vhost-options.nix);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # This isn't needed, it's just so that the user can type "nagiostats
    # -c /etc/nagios.cfg".
    environment.etc."nagios.cfg".source = nagiosCfgFile;
    environment.systemPackages = [ pkgs.nagios ];

    services.httpd.virtualHosts = lib.optionalAttrs cfg.enableWebInterface {
      ${cfg.virtualHost.hostName} = lib.mkMerge [
        cfg.virtualHost
        { extraConfig = extraHttpdConfig; }
      ];
    };

    systemd.services.nagios = {
      after = [ "network.target" ];
      description = "Nagios monitoring daemon";
      path = [ pkgs.nagios ] ++ cfg.plugins;
      restartTriggers = [ nagiosCfgFile ];

      serviceConfig = {
        ExecStart = "${pkgs.nagios}/bin/nagios /etc/nagios.cfg";
        Group = "nagios";
        LogsDirectory = "nagios";
        Restart = "always";
        RestartSec = 2;
        StateDirectory = "nagios";
        User = "nagios";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.nagios = { };

    users.users.nagios = {
      description = "Nagios user";
      group = "nagios";
      home = nagiosState;
      uid = config.ids.uids.nagios;
    };
  };

  meta.maintainers = with lib.maintainers; [ symphorien ];
}
