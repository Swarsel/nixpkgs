{ config, lib, ... }:

with lib;
let
  mergeFalseByDefault =
    locs: defs:
    if defs == [ ] then
      abort "This case should never happen."
    else if elem false (getValues defs) then
      false
    else
      true;

  kernelItem = types.submodule {
    options = {
      freeform = mkOption {
        default = null;

        description = ''
          Freeform description of a kernel configuration item value.
        '';

        example = ''MMC_BLOCK_MINORS.freeform = "32";'';
        type = types.nullOr types.str;
      };

      optional = mkOption {
        default = false;

        description = ''
          Whether option should generate a failure when unused.
          Upon merging values, mandatory wins over optional.
        '';

        type = types.bool // {
          merge = mergeFalseByDefault;
        };
      };

      tristate = mkOption {
        default = null;

        description = ''
          Use this field for tristate kernel options expecting a "y" or "m" or "n".
        '';

        internal = true;

        type = types.enum [
          "y"
          "m"
          "n"
          null
        ];

        visible = true;
      };
    };
  };

  mkValue =
    with lib;
    val:
    let
      isNumber =
        c:
        elem c [
          "0"
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
        ];

    in
    if (val == "") then
      "\"\""
    else if val == "y" || val == "m" || val == "n" then
      val
    else if all isNumber (stringToCharacters val) then
      val
    else if substring 0 2 val == "0x" then
      val
    else
      val; # FIXME: fix quoting one day

  # generate nix intermediate kernel config file of the form
  #
  #       VIRTIO_MMIO m
  #       VIRTIO_BLK y
  #       VIRTIO_CONSOLE n
  #       NET_9P_VIRTIO? y
  #
  # Borrowed from copumpkin https://github.com/NixOS/nixpkgs/pull/12158
  # returns a string, expr should be an attribute set
  # Use mkValuePreprocess to preprocess option values, aka mark 'modules' as 'yes' or vice-versa
  # use the identity if you don't want to override the configured values
  generateNixKConf =
    exprs:
    let
      mkConfigLine =
        key: item:
        let
          val = if item.freeform != null then item.freeform else item.tristate;
        in
        optionalString (val != null) (
          if (item.optional) then "${key}? ${mkValue val}\n" else "${key} ${mkValue val}\n"
        );

      mkConf = cfg: concatStrings (mapAttrsToList mkConfigLine cfg);
    in
    mkConf exprs;

in
{

  options = {

    intermediateNixConfig = mkOption {
      description = ''
        The result of converting the structured kernel configuration in settings
        to an intermediate string that can be parsed by generate-config.pl to
        answer the kernel `make defconfig`.
      '';

      example = ''
        USB? y
        DEBUG n
      '';

      readOnly = true;
      type = types.lines;
    };

    settings = mkOption {
      description = ''
        Structured kernel configuration.
      '';

      example = literalExpression ''
        with lib.kernel; {
               "9P_NET" = yes;
               USB = option yes;
               MMC_BLOCK_MINORS = freeform "32";
             }'';

      type = types.attrsOf kernelItem;
    };
  };

  config = {
    intermediateNixConfig = generateNixKConf config.settings;
  };
}
