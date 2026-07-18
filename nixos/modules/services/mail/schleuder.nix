{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.schleuder;
  settingsFormat = pkgs.formats.yaml { };
  postfixMap =
    entries: lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name} ${value}") entries);
  writePostfixMap = name: entries: pkgs.writeText name (postfixMap entries);
  configScript = pkgs.writeScript "schleuder-cfg" ''
    #!${pkgs.runtimeShell}
    set -exuo pipefail
    umask 0077
    ${pkgs.yq}/bin/yq \
      --slurpfile overrides <(${pkgs.yq}/bin/yq . <${lib.escapeShellArg cfg.extraSettingsFile}) \
      < ${settingsFormat.generate "schleuder.yml" cfg.settings} \
      '. * $overrides[0]' \
      > /etc/schleuder/schleuder.yml
    chown schleuder: /etc/schleuder/schleuder.yml
  '';
in
{
  options.services.schleuder = {
    enable = lib.mkEnableOption "Schleuder secure remailer";

    enablePostfix = lib.mkEnableOption "automatic postfix integration" // {
      default = true;
    };

    extraSettingsFile = lib.mkOption {
      default = null;
      description = "YAML file to merge into the schleuder config at runtime. This can be used for secrets such as API keys.";
      type = lib.types.nullOr lib.types.path;
    };

    listDefaults = lib.mkOption {
      default = { };

      description = ''
        Default settings for lists (list-defaults.yml).

        Check the [example configuration](https://0xacab.org/schleuder/schleuder/-/blob/master/etc/list-defaults.yml) for possible values.
      '';

      type = settingsFormat.type;
    };

    lists = lib.mkOption {
      default = [ ];

      description = ''
        List of list addresses that should be handled by Schleuder.

        Note that this is only handled by the postfix integration, and
        the setup of the lists, their members and their keys has to be
        performed separately via schleuder's API, using a tool such as
        schleuder-cli.
      '';

      example = [
        "widget-team@example.com"
        "security@example.com"
      ];

      type = lib.types.listOf lib.types.str;
    };

    /*
      maybe one day....
      domains = lib.mkOption {
      description = "Domains for which all mail should be handled by Schleuder.";
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["securelists.example.com"];
      };
    */
    settings = lib.mkOption {
      default = { };

      description = ''
        Settings for schleuder.yml.

        Check the [example configuration](https://0xacab.org/schleuder/schleuder/blob/master/etc/schleuder.yml) for possible values.
      '';

      type = lib.types.submodule {
        options.keyserver = lib.mkOption {
          default = "keys.openpgp.org";

          description = ''
            Key server from which to fetch and update keys.

            Note that NixOS uses a different default from upstream, since the upstream default sks-keyservers.net is deprecated.
          '';

          type = lib.types.str;
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings.api ? valid_api_keys);

        message = ''
          services.schleuder.settings.api.valid_api_keys is set. Defining API keys via NixOS config results in them being copied to the world-readable Nix store. Please use the extraSettingsFile option to store API keys in a non-public location.
        '';
      }
      {
        assertion = !(lib.any (db: db ? password) (lib.attrValues cfg.settings.database or { }));

        message = ''
          A password is defined for at least one database in services.schleuder.settings.database. Defining passwords via NixOS config results in them being copied to the world-readable Nix store. Please use the extraSettingsFile option to store database passwords in a non-public location.
        '';
      }
    ];

    environment.etc."schleuder/list-defaults.yml".source =
      settingsFormat.generate "list-defaults.yml" cfg.listDefaults;

    environment.etc."schleuder/schleuder.yml" = lib.mkIf (cfg.extraSettingsFile == null) {
      source = settingsFormat.generate "schleuder.yml" cfg.settings;
    };

    environment.systemPackages = [
      pkgs.schleuder-cli
    ];

    services.postfix = lib.mkIf cfg.enablePostfix {
      extraMasterConf = ''
        schleuder  unix  -       n       n       -       -       pipe
          flags=DRhu user=schleuder argv=/${pkgs.schleuder}/bin/schleuder work ''${recipient}
      '';

      # review: does this make sense?
      localRecipients = lib.mkIf (cfg.lists != [ ]) cfg.lists;
      settings.main.schleuder_destination_recipient_limit = 1;
      transport = lib.mkIf (cfg.lists != [ ]) (postfixMap (lib.genAttrs cfg.lists (_: "schleuder:")));
    };

    services.schleuder = {
      #lists_dir = "/var/lib/schleuder.lists";
      settings.filters_dir = lib.mkDefault "/var/lib/schleuder/filters";
      settings.keyword_handlers_dir = lib.mkDefault "/var/lib/schleuder/keyword_handlers";
    };

    systemd.services =
      let
        commonServiceConfig = {
          StateDirectory = "schleuder";
          StateDirectoryMode = "0700";
          # We would have liked to use DynamicUser, but since the default
          # database is SQLite and lives in StateDirectory, and that same
          # database needs to be readable from the postfix service, this
          # isn't trivial to do.
          User = "schleuder";
        };
      in
      {
        schleuder-api-daemon = {
          after = [
            "local-fs.target"
            "network.target"
            "schleuder-init.service"
          ];

          requires = [ "schleuder-init.service" ];

          serviceConfig = commonServiceConfig // {
            ExecStart = [ "${pkgs.schleuder}/bin/schleuder-api-daemon" ];
          };

          wantedBy = [ "multi-user.target" ];
        };

        schleuder-init = {
          serviceConfig = commonServiceConfig // {
            ExecStart = [ "${pkgs.schleuder}/bin/schleuder install" ];

            ExecStartPre = lib.mkIf (cfg.extraSettingsFile != null) [
              "+${configScript}"
            ];

            Type = "oneshot";
          };
        };

        schleuder-weekly-key-maintenance = {
          after = [
            "local-fs.target"
            "network.target"
          ];

          serviceConfig = commonServiceConfig // {
            ExecStart = [
              "${pkgs.schleuder}/bin/schleuder refresh_keys"
              "${pkgs.schleuder}/bin/schleuder check_keys"
            ];
          };

          startAt = "weekly";
        };
      };

    users.groups.schleuder = { };
    users.users.schleuder.group = "schleuder";
    users.users.schleuder.isSystemUser = true;
  };
}
