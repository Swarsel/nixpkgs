{
  lib,
  MenhirLib,
  coq,
  mkCoqDerivation,
  parsec,
  version ? null,
}:

(mkCoqDerivation {
  inherit version;
  pname = "json";

  propagatedBuildInputs = [
    parsec
    MenhirLib
    coq.ocamlPackages.menhir
  ];

  defaultVersion =
    let
      case = case: out: { inherit case out; };
      inherit (lib.versions) range;
    in
    lib.switch coq.coq-version [
      (case (range "8.14" "9.1") "0.2.0")
      (case (range "8.14" "8.20") "0.1.3")
    ] null;

  owner = "liyishuai";

  release = {
    "0.1.3".hash = "sha256-lElAzW4IuX+BB6ngDjlyKn0MytLRfbhQanB+Lct/WR0=";
    "0.2.0".hash = "sha256-qDRTgWLUvu4x3/d3BDcqo2I4W5ZmLyRiwuY/Tm/FuKA=";
  };

  releaseRev = v: "v${v}";
  repo = "coq-json";
  useDuneifVersion = v: lib.versions.isGe "0.2.0" v || v == "dev";

  meta = {
    description = "From JSON to Coq, and vice versa";
    license = lib.licenses.bsd3;
  };
}).overrideAttrs
  (
    o:
    lib.optionalAttrs (o.version != null && lib.versions.isLt "0.2.0" o.version) {
      buildFlags = [
        "MENHIRFLAGS=--coq"
        "MENHIRFLAGS+=--coq-no-version-check"
      ];
    }
  )
