{
  lib,
  QuickChick,
  async-test,
  coq,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "http";

  propagatedBuildInputs = [
    QuickChick
    async-test
  ];

  configurePhase = ''
    sed -e 's/^	install extract.*//' -i Makefile
  '';

  defaultVersion =
    let
      case = case: out: { inherit case out; };
      inherit (lib.versions) range;
    in
    lib.switch coq.coq-version [
      (case (range "8.14" "8.19") "0.2.1")
    ] null;

  owner = "liyishuai";

  release = {
    "0.2.1".hash = "sha256-CIcaXEojNdajXNoMBjGlQRc1sOJSKgUlditNxbNSPgk=";
  };

  releaseRev = v: "v${v}";
  repo = "coq-http";

  meta = {
    description = "HTTP specification in Coq, testable and verifiable";
    license = lib.licenses.mpl20;
  };
}
