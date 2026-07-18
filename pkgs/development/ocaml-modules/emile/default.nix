{
  lib,
  fetchurl,
  alcotest,
  angstrom,
  base64,
  buildDunePackage,
  cmdliner,
  ipaddr,
  pecu,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "emile";
  version = "1.1";

  src = fetchurl {
    url = "https://github.com/dinosaure/emile/releases/download/v${finalAttrs.version}/emile-v${finalAttrs.version}.tbz";
    hash = "sha256:0r1141makr0b900aby1gn0fccjv1qcqgyxib3bzq8fxmjqwjan8p";
  };

  buildInputs = [ cmdliner ];

  propagatedBuildInputs = [
    angstrom
    ipaddr
    base64
    pecu
    uutf
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Parser of email address according RFC822";
    homepage = "https://github.com/dinosaure/emile";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
