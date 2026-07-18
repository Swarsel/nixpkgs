{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "rewriter";
  propagatedBuildInputs = [ stdlib ];

  defaultVersion =
    let
      inherit (lib.versions) range;
    in
    lib.switch coq.coq-version [
      {
        case = range "8.17" "9.2";
        out = "0.0.15";
      }
    ] null;

  mlPlugin = true;
  owner = "mit-plv";

  release = {
    "0.0.15".hash = "sha256-zxNIMppFXUKShOXLbdZphy0Je5ii6cjcWUUcQMTcaHk=";
  };

  releaseRev = v: "v${v}";

  meta = {
    description = "Reflective PHOAS rewriting/pattern-matching-compilation framework for simply-typed equalities and let-lifting, experimental and tailored for use in Fiat Cryptography";
    license = lib.licenses.mit;
  };
}
