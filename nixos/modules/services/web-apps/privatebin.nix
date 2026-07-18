{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.privatebin;

  customToINI = lib.generators.toINI {
    mkKeyValue = lib.generators.mkKeyValueDefault {
      mkValueString =
        v:
        if v == true then
          "true"
        else if v == false then
          "false"
        else if builtins.isInt v then
          "${toString v}"
        else if builtins.isPath v then
          ''"${toString v}"''
        else if builtins.isString v then
          ''"${v}"''
        else
          lib.generators.mkValueStringDefault { } v;
    } "=";
  };

  privatebinSettings = pkgs.writeTextDir "conf.php" (customToINI cfg.settings);

  user = cfg.user;
  group = cfg.group;

  defaultUser = "privatebin";
  defaultGroup = "privatebin";

in
{

  options.services.privatebin = {

    enable = lib.mkEnableOption "Privatebin: A minimalist, open source online
      pastebin where the server has zero knowledge of pasted data.";

    package = lib.mkPackageOption pkgs "privatebin" { };

    dataDir = lib.mkOption {
      default = "/var/lib/privatebin";

      description = ''
        The place where privatebin stores its state.
      '';

      type = lib.types.path;
    };

    enableNginx = lib.mkOption {
      default = false;

      description = ''
        Whether to enable nginx or not. If enabled, an nginx virtual host will
        be created for access to privatebin. If not enabled, then you may use
        `''${config.services.privatebin.package}` as your document root in
        whichever webserver you wish to setup.
      '';

      type = lib.types.bool;
    };

    group = lib.mkOption {
      default = if cfg.enableNginx then "nginx" else defaultGroup;
      defaultText = lib.literalExpression "if config.services.privatebin.enableNginx then \"nginx\" else \"${defaultGroup}\"";

      description = ''
        Group under which privatebin runs. It is best to set this to the group
        of whatever webserver is being used as the frontend.
      '';

      type = lib.types.str;
    };

    poolConfig = lib.mkOption {
      default = { };

      defaultText = lib.literalExpression ''
        {
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 4;
          "pm.max_requests" = 500;
        }
      '';

      description = ''
        Options for the PrivateBin PHP pool. See the documentation on <literal>php-fpm.conf</literal>
        for details on configuration directives.
      '';

      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.int
          lib.types.bool
        ]
      );
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Options for privatebin configuration. Refer to
        <https://github.com/PrivateBin/PrivateBin/wiki/Configuration> for
        details on supported values.
      '';

      example = lib.literalExpression ''
        {
          main = {
            name = "NixOS Based Privatebin";
            discussion = false;
            defaultformatter = "plalib.types.intext";
            qrcode = true
          };
          model.class = "Filesystem";
          model_options.dir = "/var/lib/privatebin/data";
        }
      '';

      type = lib.types.submodule { freeformType = lib.types.attrsOf lib.types.anything; };
    };

    user = lib.mkOption {
      default = defaultUser;
      description = "User account under which privatebin runs.";
      type = lib.types.str;
    };

    virtualHost = lib.mkOption {
      default = "localhost";

      description = ''
        The hostname at which you wish privatebin to be served. If you have
        enabled nginx using `services.privatebin.enableNginx` then this will
        be used.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = lib.mkIf cfg.enableNginx {
      enable = true;
      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;

      virtualHosts.${cfg.virtualHost} = {
        locations = {
          "/" = {
            extraConfig = ''
              sendfile off;
            '';

            index = "index.php";
            tryFiles = "$uri $uri/ /index.php?$query_string";
          };

          "~ \\.php$" = {
            extraConfig = ''
              include ${config.services.nginx.package}/conf/fastcgi_params ;
              fastcgi_param SCRIPT_FILENAME $request_filename;
              fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
              fastcgi_pass unix:${config.services.phpfpm.pools.privatebin.socket};
            '';
          };
        };

        root = "${cfg.package}";
      };
    };

    services.phpfpm.pools.privatebin = {
      inherit user group;
      phpEnv.CONFIG_PATH = lib.strings.removeSuffix "/conf.php" (toString privatebinSettings);

      phpOptions = ''
        log_errors = on
      '';

      phpPackage = pkgs.php83;

      settings = {
        "listen.group" = lib.mkDefault group;
        "listen.mode" = lib.mkDefault "0660";
        "listen.owner" = lib.mkDefault user;
        "pm" = lib.mkDefault "dynamic";
        "pm.max_children" = lib.mkDefault 32;
        "pm.max_requests" = lib.mkDefault 500;
        "pm.max_spare_servers" = lib.mkDefault 4;
        "pm.min_spare_servers" = lib.mkDefault 2;
        "pm.start_servers" = lib.mkDefault 2;
      };
    };

    services.privatebin.settings = {
      main = lib.mkDefault { };
      model.class = lib.mkDefault "Filesystem";
      model_options.dir = lib.mkDefault "${cfg.dataDir}/data";
      purge.dir = lib.mkDefault "${cfg.dataDir}/purge";

      traffic = {
        dir = lib.mkDefault "${cfg.dataDir}/traffic";
        header = "X_FORWARDED_FOR";
      };
    };

    systemd.tmpfiles.settings."10-privatebin" =
      lib.attrsets.genAttrs
        [
          "${cfg.dataDir}/data"
          "${cfg.dataDir}/traffic"
          "${cfg.dataDir}/purge"
        ]
        (n: {
          d = {
            group = group;
            mode = "0750";
            user = user;
          };
        });

    users = {
      groups = lib.mkIf (group == defaultGroup) { ${defaultGroup} = { }; };

      users = lib.mkIf (user == defaultUser) {
        ${defaultUser} = {
          inherit group;
          description = "Privatebin service user";
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };
}
