{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "peg";
  version = "0.1.20";

  src = fetchurl {
    url = "${finalAttrs.meta.homepage}/peg-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-uLcXvJOll2ijXWUlZ5pODOlOa/ZvkrrPKXnGR0VytFo=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "strip" '$(STRIP)'
  '';

  preBuild = "makeFlagsArray+=( PREFIX=$out )";

  meta = {
    description = "Tools for generating recursive-descent parsers: programs that perform pattern matching on text";
    homepage = "http://piumarta.com/software/peg/";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
