{
  lib,
  fetchurl,
  alcotest,
  bigstringaf,
  buildDunePackage,
  crowbar,
  fmt,
  hxd,
}:

buildDunePackage (finalAttrs: {
  pname = "duff";
  version = "0.5";

  src = fetchurl {
    url = "https://github.com/mirage/duff/releases/download/v${finalAttrs.version}/duff-${finalAttrs.version}.tbz";
    sha256 = "sha256-+UU89Ko7aFDv6MxvE/BT6+XyER+vF3zqv7sD5dmtbt4=";
  };

  propagatedBuildInputs = [ fmt ];
  doCheck = true;

  checkInputs = [
    alcotest
    crowbar
    hxd
    bigstringaf
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Pure OCaml implementation of libXdiff (Rabin’s fingerprint)";
    homepage = "https://github.com/mirage/duff";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
