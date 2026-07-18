{
  lib,
  mathcomp,
  mathcomp-bigenough,
  mkRocqDerivation,
  rocq-core,
  version ? null,
}:

mkRocqDerivation {

  inherit version;
  pname = "real-closed";

  propagatedBuildInputs = [
    mathcomp.field
    mathcomp-bigenough
  ];

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
      [ rocq-core.version mathcomp.version ]
      [
        (case (range "9.0" "9.2") (isGe "2.5.0") "2.0.5")
      ]
      null;

  namePrefix = [
    "rocq-core"
    "mathcomp"
  ];

  owner = "math-comp";

  release = {
    "2.0.5".sha256 = "sha256-nns1TF3isv8FpWqtXilfMEVKvR50fvS6MXnYVzbCzVs=";
  };

  meta = {
    description = "Mathematical Components Library on real closed fields";
    license = lib.licenses.cecill-c;
  };
}
