{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "coinduction";
  propagatedBuildInputs = [ stdlib ];

  defaultVersion =
    let
      inherit (lib.versions) range;
    in
    lib.switch coq.coq-version [
      {
        case = range "8.19" "8.19";
        out = "1.9";
      }
    ] null;

  mlPlugin = true;
  owner = "damien-pous";

  release = {
    "1.9".hash = "sha256-bBU+xDklnzJBeN41GarW5KXzD8eKsOYtb//ULYumwWE=";
  };

  releaseRev = v: "v${v}";

  meta = {
    description = "Library for doing proofs by (enhanced) coinduction";
    license = lib.licenses.lgpl3Plus;
  };
}
