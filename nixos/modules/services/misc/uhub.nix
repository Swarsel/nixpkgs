{
  config,
  lib,
  pkgs,
  ...
}:
let
  settingsFormat = {
    generate =
      name: attrs:
      pkgs.writeText name (
        lib.strings.concatStringsSep "\n" (
          lib.attrsets.mapAttrsToList (key: value: "${key}=${builtins.toJSON value}") attrs
        )
      );

    type =
      with lib.types;
      attrsOf (oneOf [
        bool
        int
        str
      ]);
  };
in
{
  options = {

    services.uhub = lib.mkOption {
      default = { };
      description = "Uhub ADC hub instances";

      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {

            enable = lib.mkEnableOption "hub instance" // {
              default = true;
            };

            enableTLS = lib.mkOption {
              default = false;
              description = "Whether to enable TLS support.";
              type = lib.types.bool;
            };

            plugins = lib.mkOption {
              default = [ ];
              description = "Uhub plugin configuration.";

              type =
                with lib.types;
                listOf (submodule {
                  options = {
                    plugin = lib.mkOption {
                      description = "Path to plugin file.";
                      example = lib.literalExpression "$${pkgs.uhub}/plugins/mod_auth_sqlite.so";
                      type = path;
                    };

                    settings = lib.mkOption {
                      description = "Settings specific to this plugin.";

                      example = {
                        file = "/etc/uhub/users.db";
                      };

                      type = with types; attrsOf str;
                    };
                  };
                });
            };

            settings = lib.mkOption {
              inherit (settingsFormat) type;
              default = { };

              description = ''
                Configuration of uhub.
                See <https://www.uhub.org/doc/config.php> for a list of options.
              '';

              example = {
                hub_description = "Yet another ADC hub";
                hub_name = "My Public Hub";
                max_users = 150;
                server_bind_addr = "any";
                server_port = 1511;
              };
            };

          };
        }
      );
    };

  };

  config =
    let
      hubs = lib.attrsets.filterAttrs (_: cfg: cfg.enable) config.services.uhub;
    in
    {

      environment.etc = lib.attrsets.mapAttrs' (
        name: cfg:
        let
          settings' = cfg.settings // {
            file_plugins = pkgs.writeText "uhub-plugins.conf" (
              lib.strings.concatStringsSep "\n" (
                map (
                  { plugin, settings }:
                  ''plugin ${plugin} "${
                    toString (lib.attrsets.mapAttrsToList (key: value: "${key}=${value}") settings)
                  }"''
                ) cfg.plugins
              )
            );

            tls_enable = cfg.enableTLS;
          };
        in
        {
          name = "uhub/${name}.conf";
          value.source = settingsFormat.generate "uhub-${name}.conf" settings';
        }
      ) hubs;

      systemd.services = lib.attrsets.mapAttrs' (name: cfg: {
        name = "uhub-${name}";

        value =
          let
            pkg = pkgs.uhub.override { tlsSupport = cfg.enableTLS; };
          in
          {
            after = [ "network.target" ];
            description = "high performance peer-to-peer hub for the ADC network";
            reloadIfChanged = true;

            serviceConfig = {
              AmbientCapabilities = "CAP_NET_BIND_SERVICE";
              CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
              DynamicUser = true;
              ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
              ExecStart = "${pkg}/bin/uhub -c /etc/uhub/${name}.conf -L";
              Type = "notify";
            };

            wantedBy = [ "multi-user.target" ];
          };
      }) hubs;
    };

}
