{
  lib,
  coq,
  mathcomp,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "reglang";

  propagatedBuildInputs = [
    mathcomp.ssreflect
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
      [ coq.coq-version mathcomp.version ]
      [
        (case (range "8.16" "9.1") (range "2.0.0" "2.5.0") "1.2.2")
        (case (range "8.16" "9.0") (range "2.0.0" "2.3.0") "1.2.1")
        (case (range "8.16" "8.18") (range "2.0.0" "2.1.0") "1.2.0")
        (case (range "8.10" "8.20") (isLt "2.0.0") "1.1.3")
      ]
      null;

  release."1.1.2".hash = "sha256-SEnMilLNxh6a3oiDNGLaBr8quQ/nO2T9Fwdf/1il2Yk=";
  release."1.1.3".hash = "sha256-kaselYm8K0JBsTlcI6K24m8qpv8CZ9+VNDJrOtFaExg=";
  release."1.2.0".hash = "sha256-gSqQ7D2HLwM4oYopTWkMFYfYXxsH/7VxI3AyrLwNf3o=";
  release."1.2.1".hash = "sha256-giCRK8wzpVVzXAkFAieQDWqSsP7upSJSUUHkwG4QqO4=";
  release."1.2.2".hash = "sha256-js1JaLSpYbxfiAfh8XvGsnJpx5DV13heouUm3oeBfNg=";
  releaseRev = v: "v${v}";

  meta = {
    description = "Regular Language Representations in Coq";
    license = lib.licenses.cecill-b;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}
