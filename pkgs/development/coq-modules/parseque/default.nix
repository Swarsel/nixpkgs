{
  lib,
  coq,
  mkCoqDerivation,
  version ? null,
}:

let
  derivation = mkCoqDerivation {
    inherit version;
    pname = "parseque";

    defaultVersion =
      let
        case = case: out: { inherit case out; };
      in
      lib.switch coq.coq-version [
        (case (lib.versions.range "8.16" "8.20") "0.2.2")
      ] null;

    owner = "rocq-community";
    release."0.2.2".hash = "sha256-O50Rs7Yf1H4wgwb7ltRxW+7IF0b04zpfs+mR83rxT+E=";
    releaseRev = v: "v${v}";
    repo = "parseque";

    meta = {
      description = "Total parser combinators in Coq/Rocq";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ womeier ];
    };
  };
in
# this is just a wrapper for rocqPackages.parseque for Rocq >= 9.0
if coq.rocqPackages ? parseque then
  coq.rocqPackages.parseque.override {
    inherit version;
    inherit (coq.rocqPackages) rocq-core;
  }
else
  derivation
