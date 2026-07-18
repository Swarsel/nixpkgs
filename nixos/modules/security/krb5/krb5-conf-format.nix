{ lib, pkgs, ... }:

# Based on
# - https://web.mit.edu/kerberos/krb5-1.12/doc/admin/conf_files/krb5_conf.html
# - https://manpages.debian.org/unstable/heimdal-docs/krb5.conf.5heimdal.en.html

let
  inherit (lib)
    boolToString
    concatMapStringsSep
    concatStringsSep
    filter
    isAttrs
    isBool
    isList
    mapAttrsToList
    mkOption
    singleton
    splitString
    ;
  inherit (lib.types)
    attrsOf
    bool
    coercedTo
    either
    enum
    int
    listOf
    oneOf
    path
    str
    submodule
    ;
in
{
  enableKdcACLEntries ? false,
}:
rec {
  generate =
    let
      indent = str: concatMapStringsSep "\n" (line: "  " + line) (splitString "\n" str);

      formatToplevel =
        args@{
          include ? [ ],
          includedir ? [ ],
          module ? [ ],
          ...
        }:
        let
          sections = removeAttrs args [
            "include"
            "includedir"
            "module"
          ];
        in
        concatStringsSep "\n" (
          filter (x: x != "") [
            (concatStringsSep "\n" (mapAttrsToList formatSection sections))
            (concatMapStringsSep "\n" (m: "module ${m}") module)
            (concatMapStringsSep "\n" (i: "include ${i}") include)
            (concatMapStringsSep "\n" (i: "includedir ${i}") includedir)
          ]
        );

      formatSection = name: section: ''
        [${name}]
        ${indent (concatStringsSep "\n" (mapAttrsToList formatRelation section))}
      '';

      formatRelation =
        name: relation:
        if isAttrs relation then
          ''
            ${name} = {
            ${indent (concatStringsSep "\n" (mapAttrsToList formatValue relation))}
            }''
        else if isList relation then
          concatMapStringsSep "\n" (formatRelation name) relation
        else
          formatValue name relation;

      formatValue =
        name: value:
        if isList value then concatMapStringsSep "\n" (formatAtom name) value else formatAtom name value;

      formatAtom =
        name: atom:
        let
          v = if isBool atom then boolToString atom else toString atom;
        in
        "${name} = ${v}";
    in
    name: value:
    pkgs.writeText name ''
      ${formatToplevel value}
    '';

  sectionType =
    let
      relation = oneOf [
        (listOf (attrsOf value))
        (attrsOf value)
        value
      ];
      value = either (listOf atom) atom;
      atom = oneOf [
        int
        str
        bool
      ];
    in
    attrsOf relation;

  type =
    let
      aclEntry = submodule {
        options = {
          access = mkOption {
            default = "all";

            description = ''
              The changes the principal is allowed to make.

              :::{.important}
              The "all" permission does not imply the "get-keys" permission. This
              is consistent with the behavior of both MIT Kerberos and Heimdal.
              :::

              :::{.warning}
              Value "all" is allowed as a list member only if it appears alone
              or accompanied by "get-keys". Any other combination involving
              "all" will raise an exception.
              :::
            '';

            type = coercedTo str singleton (
              listOf (enum [
                "all"
                "add"
                "cpw"
                "delete"
                "get-keys"
                "get"
                "list"
                "modify"
              ])
            );
          };

          principal = mkOption {
            description = "Which principal the rule applies to";
            type = str;
          };

          target = mkOption {
            default = "*";
            description = "The principals that 'access' applies to.";
            type = str;
          };
        };
      };

      realm = submodule (
        { name, ... }:
        {
          options = {
            acl = mkOption {
              default = [
                {
                  access = "all";
                  principal = "*/admin";
                }
                {
                  access = "all";
                  principal = "admin";
                }
              ];

              description = ''
                The privileges granted to a user.
              '';

              type = listOf aclEntry;
            };
          };

          freeformType = sectionType;
        }
      );
    in
    submodule {
      options = {
        include = mkOption {
          default = [ ];

          description = ''
            Files to include in the Kerberos configuration.
          '';

          type = coercedTo path singleton (listOf path);
        };

        includedir = mkOption {
          default = [ ];

          description = ''
            Directories containing files to include in the Kerberos configuration.
          '';

          type = coercedTo path singleton (listOf path);
        };

        module = mkOption {
          default = [ ];

          description = ''
            Modules to obtain Kerberos configuration from.
          '';

          type = coercedTo path singleton (listOf path);
        };

      }
      // (lib.optionalAttrs enableKdcACLEntries {
        realms = mkOption {
          description = ''
            The realm(s) to serve keys for.
          '';

          type = attrsOf realm;
        };
      });

      freeformType = attrsOf sectionType;
    };
}
