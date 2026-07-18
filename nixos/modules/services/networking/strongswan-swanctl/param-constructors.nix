# In the following context a parameter is an attribute set that
# contains a NixOS option and a render function. It also contains the
# attribute: '_type = "param"' so we can distinguish it from other
# sets.
#
# The render function is used to convert the value of the option to a
# snippet of strongswan.conf. Most parameters simply render their
# value to a string. For example, take the following parameter:
#
#   threads = mkIntParam 10 "Threads to use for request handling.";
#
# When a users defines the corresponding option as for example:
#
#   services.strongswan-swanctl.strongswan.threads = 32;
#
# It will get rendered to the following snippet in strongswan.conf:
#
#   threads = 32
#
# Some parameters however need to be able to change the attribute
# name. For example, take the following parameter:
#
#   id = mkPrefixedAttrsOfParam (mkOptionalStrParam "") "...";
#
# A user can define the corresponding option as for example:
#
#   id = {
#     "foo" = "bar";
#     "baz" = "qux";
#   };
#
# This will get rendered to the following snippet:
#
#   foo-id = bar
#   baz-id = qux
#
# For this reason the render function is not simply a function from
# value -> string but a function from a value to an attribute set:
# { "${name}" = string }. This allows parameters to change the attribute
# name like in the previous example.

lib:

with lib;
with (import ./param-lib.nix lib);

rec {
  documentDefault =
    description: strongswanDefault:
    if strongswanDefault == null then
      description
    else
      (
        description
        + ''


          StrongSwan default: ````${builtins.toJSON strongswanDefault}````
        ''
      );

  mkAttrsOf = param: option: description: {
    _type = "param";

    option = mkOption {
      default = { };
      description = description;
      type = types.attrsOf option;
    };

    render = single (attrs: (paramsToRenderedStrings attrs (mapAttrs (_n: _v: param) attrs)));
  };

  mkAttrsOfParam = param: mkAttrsOf param param.option.type;
  mkAttrsOfParams = params: mkAttrsOf params (types.submodule { options = paramsToOptions params; });
  mkCommaSepListParam = mkSepListParam ",";
  # TODO: Check for duration format:
  mkDurationParam = mkStrParam;
  mkEnumParam = values: mkParamOfType (types.enum values);
  # We should have floats in Nix...
  mkFloatParam = mkStrParam;
  # TODO: Check for hex format:
  mkHexParam = mkStrParam;
  mkIntParam = mkParamOfType types.int;
  mkOptionalDurationParam = mkOptionalStrParam;
  mkOptionalHexParam = mkOptionalStrParam;
  mkOptionalIntParam = mkIntParam null;
  mkOptionalStrParam = mkStrParam null;

  mkParamOfType = type: strongswanDefault: description: {
    _type = "param";

    option = mkOption {
      default = null;
      description = documentDefault description strongswanDefault;
      type = types.nullOr type;
    };

    render = single toString;
  };

  mkPrefixedAttrsOf = p: option: description: {
    _type = "param";

    option = mkOption {
      default = { };
      description = description;
      type = types.attrsOf option;
    };

    render =
      prefix: attrs:
      let
        prefixedAttrs = mapAttrs' (name: nameValuePair "${prefix}-${name}") attrs;
      in
      paramsToRenderedStrings prefixedAttrs (mapAttrs (_n: _v: p) prefixedAttrs);
  };

  mkPrefixedAttrsOfParam = param: mkPrefixedAttrsOf param param.option.type;

  mkPrefixedAttrsOfParams =
    params: mkPrefixedAttrsOf params (types.submodule { options = paramsToOptions params; });

  mkSepListParam = sep: strongswanDefault: description: {
    _type = "param";

    option = mkOption {
      default = null;
      description = documentDefault description strongswanDefault;
      type = types.nullOr (types.listOf types.str);
    };

    render = single (value: concatStringsSep sep value);
  };

  mkSpaceSepListParam = mkSepListParam " ";
  mkStrParam = mkParamOfType types.str;

  mkYesNoParam = strongswanDefault: description: {
    _type = "param";

    option = mkOption {
      default = null;
      description = documentDefault description strongswanDefault;
      type = types.nullOr types.bool;
    };

    render = single boolToYesNo;
  };

  no = false;
  single = f: name: value: { ${name} = f value; };
  yes = true;

}
