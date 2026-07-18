{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "atbr";
  propagatedBuildInputs = [ stdlib ];

  defaultVersion =
    let
      inherit (lib.versions) range;
    in
    lib.switch coq.coq-version [
      {
        case = range "8.20" "8.20";
        out = "8.20.0";
      }
    ] null;

  mlPlugin = true;

  release = {
    "8.20.0".hash = "sha256-Okhtq6Gnq4HA3tEZJvf8JBnmk3OKdm6hC1qINmoShmo=";
  };

  releaseRev = v: "v${v}";

  meta = {
    description = "Coq library and tactic for deciding Kleene algebras";
    license = lib.licenses.lgpl3Plus;
  };
}
