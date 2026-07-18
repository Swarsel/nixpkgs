# legacy texlive.combine wrapper
{
  lib,
  buildTeXEnv,
  tl,
  toTLPkgList,
}:
args@{
  extraName ? "combined",
  extraVersion ? "",
  pkgFilter ? (
    pkg: pkg.tlType == "run" || pkg.tlType == "bin" || pkg.pname == "core" || pkg.hasManpages or false
  ),
  ...
}:
let
  pkgSet = removeAttrs args [
    "pkgFilter"
    "extraName"
    "extraVersion"
  ];

  # combine a set of TL packages into a single TL meta-package
  combinePkgs =
    pkgList:
    lib.catAttrs "pkg" (
      let
        # a TeX package used to be an attribute set { pkgs = [ ... ]; ... } where pkgs is a list of derivations
        # the derivations make up the TeX package and optionally (for backward compatibility) its dependencies
        tlPkgToSets =
          drv:
          map (
            {
              tlType,
              outputName ? "",
              version ? "",
              ...
            }@pkg:
            {
              inherit pkg;
              # outputName required to distinguish among bin.core-big outputs
              key = "${pkg.pname or pkg.name}.${tlType}-${version}-${outputName}";
            }
          ) (drv.pkgs or (toTLPkgList drv));
        pkgListToSets = lib.concatMap tlPkgToSets;
      in
      builtins.genericClosure {
        operator =
          { pkg, ... }:
          pkgListToSets (
            if pkg ? tlDeps then if builtins.isFunction pkg.tlDeps then pkg.tlDeps tl else pkg.tlDeps else [ ]
          );

        startSet = pkgListToSets pkgList;
      }
    );
  combined = combinePkgs (lib.attrValues pkgSet);

  # convert to specified outputs
  tlTypeToOut = {
    bin = "out";
    doc = "texdoc";
    run = "tex";
    source = "texsource";
    tlpkg = "tlpkg";
  };
  toSpecified =
    { tlType, ... }@drv:
    drv
    // {
      outputSpecified = true;
      tlOutputName = tlTypeToOut.${tlType};
    };
  all = lib.filter pkgFilter combined ++ lib.filter (pkg: pkg.tlType == "tlpkg") combined;
  converted = map toSpecified all;
in
lib.addMetaAttrs
  {
    problems.removal.message = "texlive.combine is deprecated and will be removed from Nixpkgs 27.05. Please switch to texliveSmall.withPackages. See https://nixos.org/manual/nixpkgs/stable/#sec-language-texlive-user-guide.";
  }
  (buildTeXEnv {
    __combine = true;
    __extraName = extraName;
    __extraVersion = extraVersion;
    __fromCombineWrapper = true;
    requiredTeXPackages = _: converted;
  })
