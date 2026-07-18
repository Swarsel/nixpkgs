{
  lib,
  fetchFromGitHub,
  newScope,
  stdenvNoCC,
  unzip,
}:
let
  base = {
    version = "unstable-2023-01-26";
    dontBuild = true;

    meta = {
      description = "Data repository for seaborn examples";
      homepage = "https://github.com/mwaskom/seaborn-data";
      maintainers = [ ];
      platforms = lib.platforms.all;
    };
  };
  makeSeabornDataPackage =
    { hash, pname }:
    let
      src = fetchFromGitHub {
        inherit hash;
        owner = "mwaskom";
        repo = "seaborn-data";
        rev = "2b29313169bf8dfa77d8dc930f7bd3eba559a906";
        sparseCheckout = [ "${pname}.csv" ];
      };
    in
    stdenvNoCC.mkDerivation (
      base
      // {
        inherit pname src;
        version = base.version;

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cp ${pname}.csv $out/${pname}.csv

          runHook postInstall
        '';
      }
    );
in
lib.makeScope newScope (self: {
  exercise = makeSeabornDataPackage {
    pname = "exercise";
    hash = "sha256-icoc2HkG303A8hCoW6kZxD5qhOKIpdxErLr288o04wE=";
  };
})
