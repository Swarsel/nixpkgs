{ lib, pkgs }:
{
  # Format for defining configuration of some PHP services, that use "include 'config.php';" approach.
  format =
    {
      finalVariable ? null,
    }:
    let
      toPHP =
        value:
        {
          "bool" = if value then "true" else "false";
          "float" = toString value;
          "int" = toString value;
          "list" = list value;
          "null" = "null";
          "set" = attrs value;
          "string" = string value;
        }
        .${builtins.typeOf value}
        or (abort "should never happen: unknown value type ${builtins.typeOf value}");

      # https://www.php.net/manual/en/language.types.string.php#language.types.string.syntax.single
      escapeSingleQuotedString = lib.escape [
        "'"
        "\\"
      ];
      string = value: "'${escapeSingleQuotedString value}'";

      listContent = values: lib.concatStringsSep ", " (map toPHP values);
      list = values: "[" + (listContent values) + "]";

      attrsContent =
        values:
        lib.pipe values [
          (lib.mapAttrsToList (k: v: "${toPHP k} => ${toPHP v}"))
          (lib.concatStringsSep ", ")
        ];
      attrs = set: if set ? _phpType then specialType set else "[" + attrsContent set + "]";

      mixedArray =
        { list, set }: if list == [ ] then attrs set else "[${listContent list}, ${attrsContent set}]";

      specialType =
        { _phpType, value }:
        {
          "mixed_array" = mixedArray value;
          "raw" = value;
        }
        .${_phpType};

      type =
        with lib.types;
        nullOr (oneOf [
          bool
          int
          float
          str
          (attrsOf type)
          (listOf type)
        ])
        // {
          description = "PHP value";
        };
    in
    {

      inherit type;

      generate =
        name: value:
        pkgs.writeTextFile {
          inherit name;

          text =
            let
              # strict_types enabled here to easily debug problems when calling functions of incorrect type using `mkRaw`.
              phpHeader = "<?php\ndeclare(strict_types=1);\n";
            in
            if finalVariable == null then
              phpHeader + "return ${toPHP value};\n"
            else
              phpHeader + "\$${finalVariable} = ${toPHP value};\n";
        };

      lib = {
        mkMixedArray = list: set: {
          _phpType = "mixed_array";
          value = { inherit list set; };
        };

        mkRaw = raw: {
          _phpType = "raw";
          value = raw;
        };
      };

    };
}
