{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "duration";
  version = "0.3.1";

  src = fetchurl {
    url = "https://github.com/hannesm/duration/releases/download/v${finalAttrs.version}/duration-${finalAttrs.version}.tbz";
    hash = "sha256-zYjaaTlR4SEuqD4kzhf3Z+laOanOKt2gZUsy11zmjBM=";
  };

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = {
    description = "Conversions to various time units";
    homepage = "https://github.com/hannesm/duration";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
