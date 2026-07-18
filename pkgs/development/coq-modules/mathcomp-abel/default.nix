{
  lib,
  coq,
  mathcomp,
  mathcomp-real-closed,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {

  inherit version;
  pname = "abel";

  propagatedBuildInputs = [
    mathcomp.ssreflect
    mathcomp.field
    mathcomp-real-closed
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
      [ coq.coq-version mathcomp.version ]
      [
        (case (range "8.10" "8.16") (range "1.12.0" "1.15.0") "1.2.1")
        (case (range "8.10" "8.15") (range "1.12.0" "1.14.0") "1.2.0")
        (case (range "8.10" "8.14") (range "1.11.0" "1.12.0") "1.1.2")
      ]
      null;

  namePrefix = [
    "coq"
    "mathcomp"
  ];

  owner = "math-comp";
  release."1.0.0".hash = "sha256:190jd8hb8anqsvr9ysr514pm5sh8qhw4030ddykvwxx9d9q6rbp3";
  release."1.1.2".hash = "sha256:0565w713z1cwxvvdlqws2z5lgdys8lddf0vpwfdj7bpd7pq9hwxg";
  release."1.2.0".hash = "sha256:1picd4m85ipj22j3b84cv8ab3330radzrhd6kp0gpxq14dhv02c2";
  release."1.2.1".hash = "sha256-M1q6WIPBsayHde2hwlTxylH169hcTs3OuFsEkM0e3yc=";

  meta = {
    description = "Abel - Galois and Abel - Ruffini Theorems";
    license = lib.licenses.cecill-b;
    maintainers = [ lib.maintainers.cohencyril ];
  };
}
