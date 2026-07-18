{
  lib,
  buildPackages,
  writeTextFile,
}:

# See https://people.freedesktop.org/~dbn/pkg-config-guide.html#concepts
{
  name, # The name of the pc file
  cflags ? [ ],
  conflicts ? [ ],
  # keywords
  # provide a default description for convenience. it's not important but still required by pkg-config.
  description ? "Pkg-config file for ${name}",
  libs ? [ ],
  libsPrivate ? [ ],
  requires ? [ ],
  requiresPrivate ? [ ],
  url ? "",
  variables ? { },
  version ? "",
}:

let
  # only 'out' has to be changed, otherwise it would be replaced by the out of the writeTextFile
  placeholderToSubstVar = builtins.replaceStrings [ "${placeholder "out"}" ] [ "@out@" ];

  replacePlaceholderAndListToString =
    x:
    if builtins.isList x then
      placeholderToSubstVar (builtins.concatStringsSep " " x)
    else
      placeholderToSubstVar x;

  keywordsSection =
    let
      mustBeAList =
        attr: attrName: if !(lib.isList attr) then throw "'${attrName}' must be a list" else attr;
    in
    {
      "Cflags" = mustBeAList cflags "cflags";
      "Conflicts" = mustBeAList conflicts "conflicts";
      "Description" = description;
      "Libs" = mustBeAList libs "libs";
      "Libs.private" = mustBeAList libsPrivate "libsPrivate";
      "Name" = name;
      "Requires" = mustBeAList requires "requires";
      "Requires.private" = mustBeAList requiresPrivate "requiresPrivate";
      "URL" = url;
      "Version" = version;
    };

  renderVariable =
    name: value:
    lib.optionalString (
      value != "" && value != [ ]
    ) "${name}=${replacePlaceholderAndListToString value}";
  renderKeyword =
    name: value:
    lib.optionalString (
      value != "" && value != [ ]
    ) "${name}: ${replacePlaceholderAndListToString value}";

  renderSomething =
    renderFunc: attrs:
    lib.pipe attrs [
      (lib.mapAttrsToList renderFunc)
      (builtins.filter (v: v != ""))
      (lib.concatLines)
    ];

  variablesSectionRendered = renderSomething renderVariable variables;
  keywordsSectionRendered = renderSomething renderKeyword keywordsSection;

  content = [
    variablesSectionRendered
    keywordsSectionRendered
  ];
in
writeTextFile {
  checkPhase = ''${buildPackages.pkg-config}/bin/${buildPackages.pkg-config.targetPrefix}pkg-config --validate "$target"'';
  destination = "/lib/pkgconfig/${name}.pc";
  name = "${name}.pc";
  text = builtins.concatStringsSep "\n" content;
}
