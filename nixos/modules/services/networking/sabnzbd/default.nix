{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkPackageOption
    mkEnableOption
    mkOptionDefault
    mkIf
    literalExpression
    types
    ;
  inherit (lib.generators)
    mkKeyValueDefault
    mkValueStringDefault
    toKeyValue
    ;

  enumFromAttrs =
    enum_values:
    types.coercedTo (types.enum (lib.attrNames enum_values)) (name: enum_values.${name}) (
      types.enum (lib.attrValues enum_values)
    );

  cfg = config.services.sabnzbd;

  # Sabnzbd expects 0/1 instead of true/false
  fixupSettings = lib.mapAttrsRecursive (
    path: value:
    if value == true then
      1
    else if value == false then
      0
    else
      value
  );

  mandatoryGlobalSettings = {
    "__encoding__" = "utf-8";
    "__version__" = 19;
  };
  allSettings = fixupSettings (mandatoryGlobalSettings // cfg.settings);

  configObjIni = pkgs.formats.configobj;

  publicSettingsIni =
    if cfg.configFile != null then
      cfg.configFile
    else
      (configObjIni { }).generate "public-settings.ini" allSettings;

  sabnzbdIniPath =
    if cfg.configFile != null then cfg.configFile else "/var/lib/${cfg.stateDir}/sabnzbd.ini";
in

{
  options = {
    services.sabnzbd = {
      enable = mkEnableOption "the sabnzbd server";
      package = mkPackageOption pkgs "sabnzbd" { };

      allowConfigWrite = mkOption {
        default = lib.versionOlder config.system.stateVersion "26.05";

        description = ''
          By default we create the sabnzbd configuration read-only,
          which keeps the nixos configuration as the single source
          of truth. If you want to enable configuration of
          sabnzbd via the web interface or use options that require
          a writeable configuration, such as quota tracking, enable
          this option.
        '';

        type = types.bool;
      };

      configFile = mkOption {
        default =
          if lib.versionOlder config.system.stateVersion "26.05" then
            "/var/lib/sabnzbd/sabnzbd.ini"
          else
            null;

        description = "Path to config file (deprecated, use `settings` instead and set this value to null)";
        type = types.nullOr types.path;
      };

      group = mkOption {
        default = "sabnzbd";
        description = "Group to run the service as";
        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the sabnzbd web interface
        '';

        type = types.bool;
      };

      secretFiles = mkOption {
        default = [ ];

        description = ''
          Path to a list of ini file containing confidential settings such as credentials.
          Settings here will be merged with the rest of the configuration (with
          the secret settings taking precedence in case of conflicts, and files
          that occur later in this list taking precedence over those that
          occur earlier).
          Recommended settings:
          - misc.api_key, misc.nzb_key, misc.username, misc.password
          - misc.email_account, misc.email_pwd if email alerts are enabled
          - servers.<name>.username, servers.<name>.password
        '';

        type = with types; listOf path;
      };

      secretValues = mkOption {
        default = { };

        description = ''
          Attrset of patterns in the settings that should be replaced at
          runtime, just before the service starts, with values read from the
          given files. The files must be readable by the service user.

          Compared to the secretFiles option, secretValues allows having the
          full settings structure in Nix, and only externalizing the secret
          values themselves.
        '';

        example = lib.literalExpression ''
          {
            "@my_server_password@" = "/run/secrets/my_server_password";
            "@my_server_username@" = "/run/secrets/my_server_username";
            "@sabnzbd_api_key@" = "/run/secrets/sabnzbd_api_key";
            "@sabnzbd_nzb_key@" = "/run/secrets/sabnzbd_nzb_key";
          }
        '';

        type = with types; attrsOf path;
      };

      settings = mkOption {
        default = { };

        description = ''
          The sabnzbd configuration (see also
          [sabnzbd's wiki](https://sabnzbd.org/wiki/configuration/4.5/configure)
          for extra documentation)
        '';

        type = types.submodule {
          options = {
            misc = {
              bandwidth_max = mkOption {
                default = "";

                description = ''
                  Maximum bandwidth in bytes(!)/sec (supports prefixes). Use
                  in conjunction with `bandwidth_perc` to set a bandwidth
                  limit. Empty string disables limit.
                '';

                example = "50MB/s";
                type = types.str;
              };

              bandwidth_perc = mkOption {
                default = 0;

                description = ''
                  Percentage of `bandwidth_max` that sabnzbd is allowed to use.
                  0 means no limit.
                '';

                example = 50;
                type = types.int;
              };

              cache_limit = mkOption {
                default = "";

                description = ''
                  Size of the RAM cache, in bytes (prefixes supported).
                  Sabnzbd recommends 25% of available RAM. Empty means
                  no cache.
                '';

                example = "500M";
                type = types.str;
              };

              email_endjob = mkOption {
                default = if cfg.settings.misc.email_server != "" then "on error" else "never";
                defaultText = ''if cfg.settings.misc.email_server != "" then "on error" else "never"'';

                description = ''
                  Whether to send emails on job completion. Values are:
                  0, 'never'    -- Never
                  1, 'always'   -- Always
                  2, 'on error' -- On error
                '';

                type = enumFromAttrs {
                  "always" = 1;
                  "never" = 0;
                  "on error" = 2;
                };
              };

              email_from = mkOption {
                default = "";
                description = "'From:' field for emails (needs to be an address)";
                type = types.str;
              };

              email_full = mkOption {
                default = cfg.settings.misc.email_server != "";
                defaultText = ''cfg.settings.misc.email_server != ""'';
                description = "Whether to send alerts for full disks";
                type = types.bool;
              };

              email_rss = mkOption {
                default = false;
                description = "Whether to send alerts for jobs added by RSS feeds";
                type = types.bool;
              };

              email_server = mkOption {
                default = "";
                description = "SMTP server for email alerts (server:host)";
                type = types.str;
              };

              email_to = mkOption {
                default = "";
                description = "Receiving address for email alerts";
                type = types.str;
              };

              enable_https = mkOption {
                default = cfg.settings.misc.https_cert != null;
                defaultText = "cfg.settings.misc.https_cert != null";
                description = "Whether to enable HTTPS for the web UI";
                example = true;
                type = types.bool;
              };

              host = mkOption {
                default = "127.0.0.1";

                description = ''
                  Address for the Web UI to listen on for incoming connections.
                '';

                example = "0.0.0.0";
                type = types.str;
              };

              html_login = mkOption {
                default = true;

                description = ''
                  Prompt for login with an html login mask if enabled,
                  otherwise prompt for basic auth (useful for SSO)
                '';

                type = types.bool;
              };

              https_cert = mkOption {
                default = null;

                description = ''
                  Path to the TLS certificate for the web UI. If not set
                  and https is enabled, a self-signed certificate will
                  be generated.
                '';

                example = literalExpression "\${config.acme.certs.\${domain}.directory}/fullchain.pem";
                type = types.nullOr types.path;
              };

              https_key = mkOption {
                default = null;

                description = ''
                  Path to the TLS key for the web UI. If not set and
                  https is enabled, a self-signed certificate will be
                  generated
                '';

                example = literalExpression "\${config.acme.certs.\${domain}.directory}/key.pem";
                type = types.nullOr types.path;
              };

              inet_exposure = mkOption {
                default = "none";

                description = ''
                  Restrictions for access from non-local IP addresses.
                  Values are:
                  0, 'none'                      -- no access
                  1, 'api (add nzbs)'            -- api access only, only add nzb files
                  2, 'api (no config)'           -- api access only, config changes not allowed
                  3, 'api (full)'                -- api access only, full api access
                  4, 'api+web (auth needed)'     -- api and web ui, login required always
                  5, 'api+web (locally no auth)' -- api and web ui, login required from non-local IPs only
                '';

                type = enumFromAttrs {
                  "api (add nzbs)" = 1;
                  "api (full)" = 3;
                  "api (no config)" = 2;
                  "api+web (auth needed)" = 4;
                  "api+web (locally no auth)" = 5;
                  "none" = 0;
                };
              };

              port = mkOption {
                default = 8080;

                description = ''
                  Port for the Web UI to listen on for incoming connections.
                '';

                example = 12345;
                type = types.port;
              };
            };

            ntfosd = mkOption {
              default = { };
              description = "NotifyOSD settings";

              type = types.submodule {
                options = {
                  ntfosd_enable = mkOption {
                    default = false;

                    description = ''
                      Whether to enable NotifyOSD alerts. Does not really make sense
                      in a server environment, hence we default to false despite
                      upstream's default true.
                    '';

                    type = types.bool;
                  };
                };

                freeformType = (configObjIni { }).type;
              };
            };

            servers = mkOption {
              default = { };
              description = "Usenet provider specification";

              type = types.attrsOf (
                types.submodule {
                  options = {
                    enable = mkOption {
                      default = true;
                      description = "Enable this server by default";
                      example = false;
                      type = types.bool;
                    };

                    connections = mkOption {
                      default = 8;

                      description = ''
                        Number of parallel connections permitted by
                        the server.
                      '';

                      example = 50;
                      type = types.int;
                    };

                    displayname = mkOption {
                      description = ''
                        Human-friendly description of the server
                      '';

                      example = "Example News Provider";
                      type = types.str;
                    };

                    expire_date = mkOption {
                      default = null;

                      description = ''
                        If Notifications are enabled and an expiry date is
                        set, warn 5 days before expiry. This setting
                        does not automatically disable the server.
                        Expected format: yyyy-mm-dd
                      '';

                      type = types.nullOr types.str;
                    };

                    host = mkOption {
                      description = ''
                        Hostname of the server
                      '';

                      example = "news.example.com";
                      type = types.str;
                    };

                    name = mkOption {
                      description = ''
                        The name of the server
                      '';

                      example = "Example News Provider";
                      type = types.str;
                    };

                    optional = mkOption {
                      default = false;

                      description = ''
                        In case of connection failures, temporarily
                        disable this server. (See sabnzbd's documentation
                        for usage guides).
                      '';

                      example = true;
                      type = types.bool;
                    };

                    port = mkOption {
                      default = 563;
                      description = "Port of the server";
                      example = 443;
                      type = types.port;
                    };

                    priority = mkOption {
                      default = 0;

                      description = ''
                        Priority of this servers. Servers are queried in
                        order of priority, from highest (0) to lowest (100).
                      '';

                      type = types.int;
                    };

                    required = mkOption {
                      default = false;

                      description = ''
                        In case of connection failures, wait for the
                        server to come back online instead of skipping
                        it.
                      '';

                      example = true;
                      type = types.bool;
                    };

                    ssl = mkOption {
                      default = true;

                      description = ''
                        Whether the server supports TLS
                      '';

                      type = types.bool;
                    };

                    ssl_verify = mkOption {
                      default = "strict";

                      description = ''
                        Level of TLS verification. Supported values:
                        3, 'strict'          -- strict (normal) verification
                        2, 'allow injection' -- allow locally injected certificates
                        0, 'none'            -- no verification
                      '';

                      type = enumFromAttrs {
                        "allow injection" = 2;
                        "none" = 0;
                        "strict" = 3;
                      };
                    };

                    timeout = mkOption {
                      default = 60;

                      description = ''
                        Time, in seconds, to wait for a response before
                        attempting error recovery.
                      '';

                      type = types.int;
                    };
                  };

                  freeformType = (configObjIni { }).type;
                }
              );
            };
          };

          config = {
            misc = {
              # don't open the browser on a daemonized service
              auto_browser = mkOptionDefault false;
              # don't check for new updates since we're using the distro version
              check_new_rel = mkOptionDefault false;
              config_conversion_version = mkOptionDefault 4;
              # config_lock = 1 turns the alert that the config is read-only from an error
              # into a warning. But the warnings still come, and additionally read access
              # to the config from the web ui is blocked as well, so better keep it at 0
              # and live with the error
              # optionally, misc.helpful_warnings = 0 will silence the warnings (but not the error)
              # at the cost of also silencing other, potentially useful warnings
              # config_lock = mkOptionDefault (if !cfg.allowConfigWrite then 1 else 0);
              config_lock = mkOptionDefault false;
              notified_new_skin = mkOptionDefault true;
            };
          };

          freeformType = (configObjIni { }).type;
        };
      };

      stateDir = mkOption {
        default = "sabnzbd";
        description = "State directory of the service under /var/lib/";
        type = types.str;
      };

      user = mkOption {
        default = "sabnzbd";
        description = "User to run the service as";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.misc.port ];
    };

    systemd.services.sabnzbd =
      let
        files =
          (lib.optional cfg.allowConfigWrite sabnzbdIniPath) ++ [ publicSettingsIni ] ++ cfg.secretFiles;
        iniPathQuoted = lib.escapeShellArg sabnzbdIniPath;
      in
      {
        after = [ "network.target" ];
        description = "sabnzbd server";

        serviceConfig = {
          ExecStart = "${lib.getExe cfg.package} -d -f ${iniPathQuoted}";
          Group = cfg.group;
          GuessMainPID = "no";
          StateDirectory = cfg.stateDir;
          Type = "forking";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
      }
      // lib.optionalAttrs (cfg.configFile == null) {
        preStart = ''
          set -euo pipefail

          ${lib.toShellVar "files" files}

          # We overwrite this immediately, but the merge script requires that
          # all files exist
          # See also: nixpkgs #504224
          (touch ${iniPathQuoted} 2>/dev/null || true)

          tmpfile=$(mktemp)

          ${lib.getExe (pkgs.python3.withPackages (py: [ py.configobj ]))} \
            ${./config_merge.py} \
            "''${files[@]}" \
            > "$tmpfile"

          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (n: v: ''
              "${lib.getExe pkgs.replace-secret}" "${n}" "${v}" "$tmpfile"
            '') cfg.secretValues
          )}

          install -D \
            -m ${if cfg.allowConfigWrite then "600" else "400"} \
            -o '${cfg.user}' -g '${cfg.group}' \
            "$tmpfile" \
            ${iniPathQuoted}

          rm "$tmpfile"
        '';
      };

    users.groups = mkIf (cfg.group == "sabnzbd") {
      sabnzbd = { };
    };

    users.users = mkIf (cfg.user == "sabnzbd") {
      sabnzbd = {
        description = "sabnzbd user";
        group = cfg.group;
        isSystemUser = true;
      };
    };

    warnings = lib.optional (cfg.configFile != null) ''
      `sabnzbd.configFile` is deprecated, consider using `sabnzbd.settings` instead.
      If you have values set in `sabnzbd.settings` set, they will be ignored.
    '';
  };
}
