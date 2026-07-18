{ lib }:

with lib;
{
  options = {

    addr = mkOption {
      description = ''
        IP address, optionally with a netmask: IPADDR[/MASK]
      '';

      type = types.str;
    };

    brd = mkOption {
      default = null;

      description = ''
        The broadcast address on the interface.
      '';

      type = types.nullOr types.str;
    };

    dev = mkOption {
      default = null;

      description = ''
        The name of the device to add the address to.
      '';

      type = types.nullOr types.str;
    };

    label = mkOption {
      default = null;

      description = ''
        Each address may be tagged with a label string. In order to preserve
        compatibility with Linux-2.0 net aliases, this string must coincide with
        the name of the device or must be prefixed with the device name followed
        by colon.
      '';

      type = types.nullOr types.str;
    };

    scope = mkOption {
      default = null;

      description = ''
        The scope of the area where this address is valid.
      '';

      type = types.nullOr types.str;
    };

  };
}
