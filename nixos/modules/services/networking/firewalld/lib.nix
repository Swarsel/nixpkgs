{ lib }:

let
  inherit (lib) mkOption;
  inherit (lib.types)
    either
    enum
    nullOr
    port
    submodule
    ;
  mkPortOption =
    {
      optional ? false,
    }:
    mkOption {
      apply =
        value: if builtins.isAttrs value then "${toString value.from}-${toString value.to}" else value;

      description = "";

      type =
        let
          type = either port (submodule {
            options = {
              from = mkOption { type = port; };
              to = mkOption { type = port; };
            };
          });
        in
        if optional then (nullOr type) else type;
    };
  protocolOption = mkOption {
    description = "";

    type = enum [
      "tcp"
      "udp"
      "sctp"
      "dccp"
    ];
  };
in
{
  inherit mkPortOption;
  inherit protocolOption;
  filterNullAttrs = lib.filterAttrsRecursive (_: value: value != null);
  mkXmlAttr = name: value: { "@${name}" = value; };

  portProtocolOptions = {
    options = {
      port = mkPortOption { };
      protocol = protocolOption;
    };
  };

  toXmlAttrs = lib.mapAttrs' (name: lib.nameValuePair ("@" + name));
}
