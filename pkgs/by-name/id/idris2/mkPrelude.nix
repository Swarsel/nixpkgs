{
  lib,
  idris2-src,
  idris2-unwrapped,
  idris2-version,
  stdenvNoCC,
}:
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  excludeDrvArgNames = [
    "dependencies"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      name,
      dependencies ? [ ],
    }:
    {
      pname = name;
      version = idris2-version;
      src = idris2-src;
      strictDeps = true;
      makeFlags = "IDRIS2=${lib.getExe idris2-unwrapped}";

      env = {
        IDRIS2_PACKAGE_PATH = lib.makeSearchPath "idris2-${idris2-version}" dependencies;
        IDRIS2_PREFIX = placeholder "out";
      };

      preBuild = ''
        cd libs/${name}
      '';

      enableParallelBuilding = true;
    };
}
