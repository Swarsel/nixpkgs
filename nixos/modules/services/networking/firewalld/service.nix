{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
  format = pkgs.formats.xml { };
  lib' = import ./lib.nix { inherit lib; };
  inherit (lib')
    filterNullAttrs
    mkXmlAttr
    portProtocolOptions
    toXmlAttrs
    ;
  inherit (lib) mkOption;
  inherit (lib.types)
    attrsOf
    listOf
    nonEmptyStr
    nullOr
    strMatching
    submodule
    ;
in
{
  options.services.firewalld.services = mkOption {
    default = { };

    description = ''
      firewalld service configuration files. See {manpage}`firewalld.service(5)`.
    '';

    type = attrsOf (submodule {
      options = {
        description = mkOption {
          default = null;
          description = "Description for the service.";
          type = nullOr nonEmptyStr;
        };

        destination = mkOption {
          default = { };
          description = "Destinations for the service.";

          type = submodule {
            options = {
              ipv4 = mkOption {
                default = null;
                description = "IPv4 destination.";
                type = nullOr (strMatching "([0-9]{1,3}\\.){3}[0-9]{1,3}(/[0-9]{1,2})?");
              };

              ipv6 = mkOption {
                default = null;
                description = "IPv6 destination.";
                type = nullOr (strMatching "[0-9A-Fa-f:]{3,39}(/[0-9]{1,3})?");
              };
            };
          };
        };

        helpers = mkOption {
          default = [ ];
          description = "Helpers for the service.";
          type = listOf nonEmptyStr;
        };

        includes = mkOption {
          default = [ ];
          description = "Services to include for the service.";
          type = listOf nonEmptyStr;
        };

        ports = mkOption {
          default = [ ];
          description = "Ports of the service.";
          type = listOf (submodule portProtocolOptions);
        };

        protocols = mkOption {
          default = [ ];
          description = "Protocols for the service.";
          type = listOf nonEmptyStr;
        };

        short = mkOption {
          default = null;
          description = "Short description for the service.";
          type = nullOr nonEmptyStr;
        };

        sourcePorts = mkOption {
          default = [ ];
          description = "Source ports for the service.";
          type = listOf (submodule portProtocolOptions);
        };

        version = mkOption {
          default = null;
          description = "Version of the service.";
          type = nullOr nonEmptyStr;
        };
      };
    });
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "firewalld/services/${name}.xml" {
        source = format.generate "firewalld-service-${name}.xml" {
          service = filterNullAttrs (
            lib.mergeAttrsList [
              (toXmlAttrs { inherit (value) version; })
              {
                inherit (value) short description;
                destination = toXmlAttrs value.destination;
                helper = map (mkXmlAttr "name") value.helpers;
                include = map (mkXmlAttr "service") value.includes;
                port = map toXmlAttrs value.ports;
                protocol = map (mkXmlAttr "value") value.protocols;
                source-port = map toXmlAttrs value.sourcePorts;
              }
            ]
          );
        };
      }
    ) cfg.services;
  };
}
