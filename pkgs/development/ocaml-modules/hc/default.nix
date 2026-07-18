{
  lib,
  buildDunePackage,
  fetchzip,
}:

buildDunePackage (finalAttrs: {
  pname = "hc";
  version = "0.5";

  # upstream git server is misconfigured and cannot be cloned
  src = fetchzip {
    url = "https://git.zapashcanon.fr/zapashcanon/hc/archive/${finalAttrs.version}.tar.gz";
    hash = "sha256-oTomFi+e9aCgVpZ9EkxQ/dZz18cW2UcaV0ZIokeBoU0=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.12";

  meta = {
    description = "Library for hash consing";
    homepage = "https://ocaml.org/p/hc/";
    changelog = "https://git.zapashcanon.fr/zapashcanon/hc/src/tag/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    downloadPage = "https://git.zapashcanon.fr/zapashcanon/hc";
  };
})
