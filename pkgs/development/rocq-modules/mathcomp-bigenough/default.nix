{
  lib,
  mathcomp-boot,
  mkRocqDerivation,
  rocq-core,
  version ? null,
}:

mkRocqDerivation {

  inherit version;
  pname = "bigenough";
  propagatedBuildInputs = [ mathcomp-boot ];

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch rocq-core.rocq-version [
      (case (range "9.0" "9.1") "1.0.4")
    ] null;

  namePrefix = [
    "rocq-core"
    "mathcomp"
  ];

  owner = "math-comp";

  release = {
    "1.0.4".sha256 = "sha256-cwfDCEFSXWnqV5aIrhTviUti0CXNwmFe6zVbqlD2iZw=";
  };

  meta = {
    description = "Small library to do epsilon - N reasonning";
    license = lib.licenses.cecill-b;
  };
}
