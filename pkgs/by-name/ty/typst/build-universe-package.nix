{
  lib,
  buildTypstPackage,
  fetchzip,
  typstPackages,
}:
lib.extendMkDerivation {
  constructDrv = buildTypstPackage;

  excludeDrvArgNames = [
    "description"
    "hash"
    "license"
    "homepage"
    "typstDeps"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      description,
      hash,
      license,
      pname,
      version,
      homepage ? null,
      typstDeps ? [ ],
    }:
    {
      src = fetchzip {
        inherit hash;
        url = "https://packages.typst.org/preview/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
        stripRoot = false;
      };

      typstDeps = builtins.filter (x: x != null) (
        lib.map (d: (lib.attrsets.attrByPath [ d ] null typstPackages)) typstDeps
      );

      meta = {
        inherit description;
        license = lib.map (lib.flip lib.getAttr lib.licensesSpdx) license;

        maintainers = with lib.maintainers; [
          cherrypiejam
          RossSmyth
        ];

        # Sending a bunch of trivial jobs to Hydra is not that great.
        hydraPlatforms = [ ];
      }
      // lib.optionalAttrs (homepage != null) { inherit homepage; };
    };

  inheritFunctionArgs = false;
}
