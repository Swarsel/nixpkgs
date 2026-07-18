{
  lib,
  coq,
  mathcomp-ssreflect,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "lemma-overloading";
  propagatedBuildInputs = [ mathcomp-ssreflect ];

  defaultVersion =
    with lib.versions;
    lib.switch
      [ coq.coq-version mathcomp-ssreflect.version ]
      [
        {
          cases = [
            (range "8.10" "8.12")
            (range "1.7" "1.11")
          ];

          out = "8.12.0";
        }
        {
          cases = [
            (range "8.10" "8.11")
            (range "1.7" "1.11")
          ];

          out = "8.11.0";
        }
        {
          cases = [
            (range "8.8" "8.11")
            (range "1.7" "1.10")
          ];

          out = "8.10.0";
        }
        {
          cases = [
            (range "8.8" "8.9")
            (range "1.7" "1.8")
          ];

          out = "8.9.0";
        }
        {
          cases = [
            (isEq "8.8")
            (range "1.6.2" "1.7")
          ];

          out = "8.8.0";
        }
      ]
      null;

  release = {
    "8.10.0".hash = "sha256-qpHh/iz2fFtGwUedjJ6fuOh8uq1mlL4ETxc9zDJ6800=";
    "8.11.0".hash = "sha256-RI3KdSEYxUbjfZWKO7atGdEqDU8WmLJSFeF6TLlgUFc=";
    "8.12.0".hash = "sha256-ul1IhxFwhLTy3+rmo3gvjHI3Z8A8avN0Rzq0YDy2bjs=";
    "8.8.0".hash = "sha256-Iq3KfESMnZF8hhGKuvZHx+hAMEaoCP7MhhQEI6xfoO8=";
    "8.9.0".hash = "sha256-dE9O94DvcF93TUTU7ky9pvGZgTtPZWz6826b6Js/nHc=";
  };

  releaseRev = v: "v${v}";

  meta = {
    description = "Libraries demonstrating design patterns for programming and proving with canonical structures in Coq";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ cohencyril ];
  };
}
