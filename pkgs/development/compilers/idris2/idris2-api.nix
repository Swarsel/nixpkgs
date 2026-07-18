{ lib, idris2Packages }:
let
  inherit (idris2Packages) idris2 buildIdris;
  apiPkg = buildIdris {
    inherit (idris2.unwrapped) src version;

    preBuild = ''
      export IDRIS2_PREFIX=$out/lib
      make src/IdrisPaths.idr
    '';

    idrisLibraries = [ ];
    ipkgName = "idris2api";

    meta = {
      inherit (idris2.meta) platforms;
      description = "Idris2 Compiler API Library";
      homepage = "https://github.com/idris-lang/Idris2";
      license = lib.licenses.bsd3;
      maintainers = with lib.maintainers; [ mattpolzin ];
    };
  };
in
apiPkg.library { }
