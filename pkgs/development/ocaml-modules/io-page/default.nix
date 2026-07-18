{
  lib,
  fetchurl,
  bigarray-compat,
  buildDunePackage,
  cstruct,
  ounit,
  pkg-config,
}:

buildDunePackage (finalAttrs: {
  pname = "io-page";
  version = "3.0.0";

  src = fetchurl {
    url = "https://github.com/mirage/io-page/releases/download/v${finalAttrs.version}/io-page-${finalAttrs.version}.tbz";
    hash = "sha256-DjbKdNkFa6YQgJDLmLsuvyrweb4/TNvqAiggcj/3hu4=";
  };

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    cstruct
    bigarray-compat
  ];

  doCheck = true;
  checkInputs = [ ounit ];
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "IO memory page library for Mirage backends";
    homepage = "https://github.com/mirage/io-page";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
