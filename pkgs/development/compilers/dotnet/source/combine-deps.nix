{
  baseRid,
  list,
  otherRids,
  pkgs ? import ../../../../.. { },
}:
let
  inherit (pkgs) writeText;

  inherit (pkgs.lib)
    concatMap
    concatMapStringsSep
    generators
    importJSON
    optionals
    replaceStrings
    sortOn
    strings
    unique
    ;

  packages = concatMap (file: importJSON file) list;

  changePackageRid =
    package: rid:
    let
      replace = replaceStrings [ ".${baseRid}" ] [ ".${rid}" ];
    in
    rec {
      inherit (package) version;
      pname = replace package.pname;
      sha256 = builtins.hashFile "sha256" (builtins.fetchurl url);
      url = replace package.url;
    };

  expandPackage =
    package:
    [ package ]
    ++ optionals (strings.match ".*\\.${baseRid}(\\..*|$)" package.pname != null) (
      map (changePackageRid package) otherRids
    );

  allPackages = sortOn (package: [
    package.pname
    package.version
  ]) (concatMap expandPackage packages);

in
writeText "deps.json" (builtins.toJSON allPackages)
