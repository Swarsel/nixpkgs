{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  eqaf,
  fmt,
}:

buildDunePackage (finalAttrs: {
  pname = "callipyge";
  version = "0.2";

  src = fetchurl {
    url = "https://github.com/oklm-wsh/Callipyge/releases/download/v${finalAttrs.version}/callipyge-${finalAttrs.version}.tbz";
    hash = "sha256-T/94a88xvK51TggjXecdKc9kyTE9aIyueIt5T24sZB0=";
  };

  propagatedBuildInputs = [
    fmt
    eqaf
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Curve25519 in OCaml";
    homepage = "https://github.com/oklm-wsh/Callipyge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fufexan ];
  };
})
