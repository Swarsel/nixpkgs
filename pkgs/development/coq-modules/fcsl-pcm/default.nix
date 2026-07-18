{
  lib,
  coq,
  mathcomp-algebra,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "fcsl-pcm";

  propagatedBuildInputs = [
    mathcomp-algebra
    stdlib
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
      [ coq.coq-version mathcomp-algebra.version ]
      [
        (case (range "9.0" "9.1") (range "2.4.0" "2.5.0") "2.2.0")
      ]
      null;

  owner = "imdea-software";
  release."2.2.0".hash = "sha256-VnfK+RHWiq27hxEJ9stpVp609/dMiPH6UHFhzaHdAnM=";
  releaseRev = v: "v${v}";

  meta = {
    description = "Coq library of Partial Commutative Monoids";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.proux01 ];
  };
}
