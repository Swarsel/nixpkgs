{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  fmt,
}:

buildDunePackage (finalAttrs: {
  pname = "metrics";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/mirage/metrics/releases/download/v${finalAttrs.version}/metrics-${finalAttrs.version}.tbz";
    sha256 = "sha256-3zVjgJCdBkYbzQl+9gY8qfPFE2X0dqeXwDZktTwFcV0=";
  };

  propagatedBuildInputs = [ fmt ];
  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.04";

  meta = {
    description = "Metrics infrastructure for OCaml";
    homepage = "https://github.com/mirage/metrics";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
