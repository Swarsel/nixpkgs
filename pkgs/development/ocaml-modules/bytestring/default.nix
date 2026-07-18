{
  lib,
  fetchurl,
  buildDunePackage,
  ppxlib,
  qcheck,
  rio,
  sedlex,
  spices,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "bytestring";
  version = "0.0.8";

  src = fetchurl {
    url = "https://github.com/riot-ml/riot/releases/download/${finalAttrs.version}/riot-${finalAttrs.version}.tbz";
    hash = "sha256-SsiDz53b9bMIT9Q3IwDdB3WKy98WSd9fiieU41qZpeE=";
  };

  propagatedBuildInputs = [
    ppxlib
    sedlex
    spices
    rio
    uutf
  ];

  # Checks fail with OCaml 5.2
  doCheck = false;

  checkInputs = [
    qcheck
  ];

  minimalOCamlVersion = "5.1";

  meta = {
    description = "Efficient, immutable, pattern-matchable, UTF friendly byte strings";
    homepage = "https://github.com/riot-ml/riot";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
