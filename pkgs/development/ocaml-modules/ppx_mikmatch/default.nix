{
  lib,
  fetchurl,
  buildDunePackage,
  menhir,
  ounit2,
  ppxlib,
  re,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_mikmatch";
  version = "1.5";

  src = fetchurl {
    url = "https://codeload.github.com/ahrefs/ppx_mikmatch/tar.gz/refs/tags/${finalAttrs.version}";
    hash = "sha256-tDp4iYJLzfVKB6VBWrHtT2jrHDtJCEPVplSNrXX5wek=";
    name = "ppx_mikmatch-${finalAttrs.version}.tar.gz";
  };

  nativeBuildInputs = [ menhir ];

  propagatedBuildInputs = [
    ppxlib
    re
  ];

  doCheck = true;
  checkInputs = [ ounit2 ];
  minimalOCamlVersion = "5.3";

  meta = {
    description = "Matching Regular Expressions with OCaml Patterns using Mikmatch's syntax";
    homepage = "https://github.com/ahrefs/ppx_mikmatch";
    license = lib.licenses.lgpl3Plus;

    maintainers = [
      lib.maintainers.vog
      lib.maintainers.zazedd
    ];
  };
})
