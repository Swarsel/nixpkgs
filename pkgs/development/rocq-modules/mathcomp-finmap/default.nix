{
  lib,
  mathcomp-boot,
  mkRocqDerivation,
  rocq-core,
  version ? null,
}:

mkRocqDerivation {

  inherit version;
  pname = "finmap";
  propagatedBuildInputs = [ mathcomp-boot ];

  defaultVersion =
    let
      case = rocq: mc: out: {
        inherit out;

        cases = [
          rocq
          mc
        ];
      };
    in
    with lib.versions;
    lib.switch
      [ rocq-core.rocq-version mathcomp-boot.version ]
      [
        (case (range "9.0" "9.1") (range "2.3" "2.5") "2.2.2")
      ]
      null;

  namePrefix = [
    "rocq-core"
    "mathcomp"
  ];

  owner = "math-comp";

  release = {
    "2.2.2".sha256 = "sha256-G5fSdx4MhOXtQ2H8lpyK5FuIbWAZNc7vRL3hcYmGA2o=";
  };

  meta = {
    description = "Finset and finmap library";
    license = lib.licenses.cecill-b;
  };
}
