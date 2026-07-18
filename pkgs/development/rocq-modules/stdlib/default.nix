{
  lib,
  mkRocqDerivation,
  rocq-core,
  version ? null,
}:
mkRocqDerivation {

  inherit version;
  pname = "stdlib";

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch rocq-core.version [
      (case (range "9.2" "9.2") "9.1.0")
      (case (range "9.0" "9.1") "9.0.0")
    ] null;

  mlPlugin = true;
  opam-name = "rocq-stdlib";
  owner = "rocq-prover";
  release."9.0.0".sha256 = "sha256-2l7ak5Q/NbiNvUzIVXOniEneDXouBMNSSVFbD1Pf8cQ=";
  release."9.1.0".sha256 = "sha256-D/kCMsJDg5OnP37GhvXIr2Fi/xCbgCCzoikKx5rL6p4=";
  releaseRev = v: "V${v}";
  repo = "stdlib";

  meta = {
    description = "Rocq Proof Assistant -- Standard Library";
    license = lib.licenses.lgpl21Only;
  };

}
