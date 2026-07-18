{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  unicoq,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "Mtac2";

  propagatedBuildInputs = [
    stdlib
    unicoq
  ];

  preBuild = ''
    coq_makefile -f _CoqProject -o Makefile
    patchShebangs tests/sf-5/configure.sh
  '';

  defaultVersion =
    with lib.versions;
    lib.switch coq.version [
      {
        case = isEq "9.1";
        out = "1.4-rocq${coq.coq-version}";
      }
      {
        case = range "8.19" "9.0";
        out = "1.4-coq${coq.coq-version}";
      }
    ] null;

  mlPlugin = true;
  owner = "Mtac2";
  release."1.4-coq8.19".hash = "sha256-G9eK0eLyECdT20/yf8yyz7M8Xq2WnHHaHpxVGP0yTtU=";
  release."1.4-coq8.20".hash = "sha256-3nu/8zDvdnl6WzGtw46mVcdqgkRgc6Xy8/I+lUOrSIY=";
  release."1.4-coq9.0".hash = "sha256-pAPBRCW7M46UZPJ+v/0xAT8mpQURN8czMmlrfYz/MVU=";
  release."1.4-rocq9.1".hash = "sha256-A+ac84ZfDMW2NhS/NrGIfdairXmzXxZIYGNmJIz0ReM=";
  releaseRev = v: "v${v}";

  meta = {
    description = "Typed tactic language for Coq";
    license = lib.licenses.mit;
  };
}
