{
  lib,
  mkRocqDerivation,
  rocq-core,
  stdlib,
  stdpp,
  version ? null,
}:

mkRocqDerivation {
  inherit version;
  pname = "iris";

  propagatedBuildInputs = [
    stdlib
    stdpp
  ];

  preBuild = ''
    if [[ -f coq-lint.sh ]]
    then patchShebangs coq-lint.sh
    fi
  '';

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch rocq-core.rocq-version [
      (case (range "9.0" "9.2") "4.5.0")
    ] null;

  domain = "gitlab.mpi-sws.org";
  owner = "iris";
  release."4.5.0".sha256 = "sha256-oGqo+W1prLtAwRwo2U15VGhmrkDIPPE6uMbNrTa8iAQ=";
  releaseRev = v: "iris-${v}";

  meta = {
    description = "Rocq development of the Iris Project";
    license = lib.licenses.bsd3;

    maintainers = [
      lib.maintainers.vbgl
      lib.maintainers.ineol
    ];
  };
}
