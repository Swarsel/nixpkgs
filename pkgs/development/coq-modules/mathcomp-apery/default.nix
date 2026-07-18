{
  lib,
  coq,
  coqeal,
  mathcomp,
  mathcomp-algebra-tactics,
  mathcomp-bigenough,
  mathcomp-real-closed,
  mathcomp-zify,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {

  inherit version;
  pname = "apery";

  propagatedBuildInputs = [
    mathcomp.field
    coqeal
    mathcomp-real-closed
    mathcomp-bigenough
    mathcomp-zify
    mathcomp-algebra-tactics
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
        (case (range "8.13" "8.16") (range "1.12.0" "1.17.0") "1.0.2")
      ]
      null;

  release."1.0.2".hash = "sha256-llxyMKYvWUA7fyroG1S/jtpioAoArmarR1edi3cikcY=";

  meta = {
    description = "Formally verified proof in Coq, by computer algebra, that ζ(3) is irrational";
    license = lib.licenses.cecill-c;
  };
}
