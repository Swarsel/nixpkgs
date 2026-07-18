{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "waterproof";
  propagatedBuildInputs = [ stdlib ];

  defaultVersion =
    let
      inherit (lib.versions) range;
    in
    lib.switch coq.coq-version [
      {
        case = range "8.18" "8.18";
        out = "2.1.1+8.18";
      }
    ] null;

  mlPlugin = true;
  owner = "impermeable";

  release = {
    "2.1.1+8.18".hash = "sha256-jYuQ9SPFRefNCUfn6+jEaJ4399EnU0gXPPkEDCpJYOI=";
  };

  repo = "coq-waterproof";
  useDune = true;

  meta = {
    description = "Coq proofs in a style that resembles non-mechanized mathematical proofs";
    license = lib.licenses.lgpl3Plus;
  };
}
