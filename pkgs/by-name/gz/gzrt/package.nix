{
  lib,
  stdenv,
  fetchFromGitHub,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gzrt";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "arenn";
    repo = "gzrt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2RzQ/xrtADplVqUeB6suU3fKhJePYM7EkuIV59JSR3Q=";
  };

  buildInputs = [ zlib ];

  installPhase = ''
    mkdir -p $out/bin
    cp gzrecover $out/bin
  '';

  meta = {
    description = "Gzip Recovery Toolkit";
    homepage = "https://github.com/arenn/gzrt";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "gzrecover";
  };
})
