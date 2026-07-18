{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sutils";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "baskerville";
    repo = "sutils";
    rev = finalAttrs.version;
    sha256 = "0i2g6a6xdaq3w613dhq7mnsz4ymwqn6kvkyan5kgy49mzq97va6j";
  };

  buildInputs = [ alsa-lib ];
  hardeningDisable = [ "format" ];
  prePatch = ''sed -i "s@/usr/local@$out@" Makefile'';

  meta = {
    description = "Small command-line utilities";
    homepage = "https://github.com/baskerville/sutils";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.meisternu ];
    platforms = lib.platforms.linux;
  };
})
