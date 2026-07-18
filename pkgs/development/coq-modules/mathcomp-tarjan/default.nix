{
  lib,
  coq,
  mathcomp-fingroup,
  mathcomp-ssreflect,
  mkCoqDerivation,
  version ? null,
}@args:

mkCoqDerivation {

  inherit version;
  pname = "tarjan";

  propagatedBuildInputs = [
    mathcomp-ssreflect
    mathcomp-fingroup
  ];

  defaultVersion =
    let
      case = coq: mc: out: {
        inherit out;

        cases = [
          coq
          mc
        ];
      };
    in
    with lib.versions;
    lib.switch
      [ coq.coq-version mathcomp-ssreflect.version ]
      [
        (case (range "8.16" "9.1") (range "2.0.0" "2.5.0") "1.0.4")
        (case (range "8.16" "9.1") (range "2.0.0" "2.4.0") "1.0.3")
        (case (range "8.16" "9.0") (range "2.0.0" "2.3.0") "1.0.2")
        (case (range "8.12" "8.18") (range "1.12.0" "1.17.0") "1.0.1")
        (case (range "8.10" "8.16") (range "1.12.0" "1.17.0") "1.0.0")
      ]
      null;

  namePrefix = [
    "coq"
    "mathcomp"
  ];

  owner = "math-comp";
  release."1.0.0".hash = "sha256:0r459r0makshzwlygw6kd4lpvdjc43b3x5y9aa8x77f2z5gymjq1";
  release."1.0.1".hash = "sha256-utNjFCAqC5xOuhdyKhfMZkRYJD0xv9Gt6U3ZdQ56mek=";
  release."1.0.2".hash = "sha256-U20xgA+e9KTRdvILD1cxN6ia+dlA8uBTIbc4QlKz9ss=";
  release."1.0.3".hash = "sha256-5lpOCDyH6NFzGLvnXHHAnR7Qv5oXsUyC8TLBFrIiBag=";
  release."1.0.4".hash = "sha256-fvE53jJe7/kQUI+lhO6lKdWfsFfRjOk2YGOcHUoJ6BU=";

  meta = {
    description = "Proofs of Tarjan and Kosaraju connected components algorithms";
    license = lib.licenses.cecill-b;
  };
}
