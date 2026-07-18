{
  lib,
  mkRocqDerivation,
  rocq-core,
  stdlib,
  version ? null,
}:

mkRocqDerivation {
  inherit version;
  pname = "stdpp";
  propagatedBuildInputs = [ stdlib ];

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
      (case (range "9.0" "9.2") "1.13.0")
    ] null;

  domain = "gitlab.mpi-sws.org";
  owner = "iris";
  release."1.13.0".sha256 = "sha256-kj8oBzarsLB4DDQ43yz4ViQbyzuISqext28wC2Fh3Sw=";
  releaseRev = v: "stdpp-${v}";

  meta = {
    description = "Extended “Standard Library” for Rocq";
    license = lib.licenses.bsd3;

    maintainers = [
      lib.maintainers.vbgl
      lib.maintainers.ineol
    ];
  };
}
