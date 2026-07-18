{
  lib,
  fetchurl,
  buildDunePackage,
  ppx_deriving,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "sel";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/gares/sel/releases/download/v${finalAttrs.version}/sel-${finalAttrs.version}.tbz";
    hash = "sha256-jTAjWdaoioR5+G96qoOY+JXrJY00eF7y7WhGSiFwfqg=";
  };

  buildInputs = [
    ppxlib
  ];

  propagatedBuildInputs = [
    ppx_deriving
  ];

  minimalOCamlVersion = "4.07";

  meta = {
    description = "Simple event library";
    homepage = "https://github.com/gares/sel/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
