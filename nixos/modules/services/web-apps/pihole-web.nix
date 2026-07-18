{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.pihole-web;
in
{
  options.services.pihole-web = {
    enable = lib.mkEnableOption "Pi-hole dashboard";
    package = lib.mkPackageOption pkgs "pihole-web" { };

    hostName = lib.mkOption {
      default = "pi.hole";
      description = "Domain name for the website.";
      type = lib.types.str;
    };

    ports =
      let
        portType = lib.types.submodule {
          options = {
            optional = lib.mkOption {
              default = false;
              description = "Skip the port if it cannot be bound";
              type = lib.types.bool;
            };

            port = lib.mkOption {
              description = "Port to bind";
              type = lib.types.port;
            };

            redirectSSL = lib.mkOption {
              default = false;
              description = "Redirect from this port to the first configured SSL port";
              type = lib.types.bool;
            };

            ssl = lib.mkOption {
              default = false;
              description = "Serve SSL on the port";
              type = lib.types.bool;
            };
          };
        };
      in
      lib.mkOption {
        apply =
          values:
          let
            convert =
              value:
              if (builtins.typeOf) value == "int" then
                toString value
              else if builtins.typeOf value == "set" then
                lib.strings.concatStrings [
                  (toString value.port)
                  (lib.optionalString value.optional "o")
                  (lib.optionalString value.redirectSSL "r")
                  (lib.optionalString value.ssl "s")
                ]
              else
                value;
          in
          lib.strings.concatStringsSep "," (map convert values);

        description = ''
          Port(s) for the webserver to serve on.

          If provided as a string, optionally append suffixes to control behaviour:

          - `o`: to make the port is optional - failure to bind will not be an error.
          - `s`: for the port to be used for SSL.
          - `r`: for a non-SSL port to redirect to the first available SSL port.
        '';

        example = [
          "80r"
          "443s"
        ];

        type = lib.types.listOf (
          lib.types.oneOf [
            lib.types.port
            lib.types.str
            portType
          ]
        );
      };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."pihole/versions".text = "WEB_VERSION=${cfg.package.src.tag}";

    services.pihole-ftl.settings.webserver = {
      domain = cfg.hostName;
      paths.webhome = "/";
      paths.webroot = "${cfg.package}/share/";
      port = cfg.ports;
    };
  };

  meta = {
    doc = ./pihole-web.md;
    maintainers = with lib.maintainers; [ averyvigolo ];
  };
}
