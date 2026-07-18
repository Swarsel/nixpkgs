{
  lib,
  coq,
  mkCoqDerivation,
  version ? null,
}:

let
  derivation = mkCoqDerivation {

    inherit version;
    pname = "stdlib";

    buildPhase = ''
      echo building nothing
    '';

    installPhase = ''
      echo installing nothing
      # Make an output directory rather than a file, so this is more friendly to buildEnv
      mkdir $out
    '';

    configurePhase = ''
      echo no configuration
    '';

    defaultVersion =
      let
        case = case: out: { inherit case out; };
      in
      with lib.versions;
      lib.switch coq.coq-version [
        (case (isLe "9.1") "9.0.0")
        # the < 9.0 above is artificial as stdlib was included in Coq before
      ] null;

    opam-name = "coq-stdlib";
    owner = "coq";
    release."9.0.0".hash = "sha256-2l7ak5Q/NbiNvUzIVXOniEneDXouBMNSSVFbD1Pf8cQ=";
    releaseRev = v: "V${v}";
    repo = "stdlib";

    meta = {
      description = "Compatibility metapackage for Coq Stdlib library after the Rocq renaming";
      license = lib.licenses.lgpl21Only;
    };
  };
in
# this is just a wrapper for rocqPackages.stdlib for Rocq >= 9.0
if coq.rocqPackages ? stdlib then
  coq.rocqPackages.stdlib.override {
    inherit version;
    inherit (coq.rocqPackages) rocq-core;
  }
else
  derivation
