{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maeparser";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "schrodinger";
    repo = "maeparser";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-xRyf/n8ezmMPMhlQFapVpnT2LReLe7spXB9jFC+VPRA=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    zlib
  ];

  meta = {
    description = "Maestro file parser";
    homepage = "https://github.com/schrodinger/maeparser";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.rmcgibbo ];
    platforms = lib.platforms.unix;
  };
})
