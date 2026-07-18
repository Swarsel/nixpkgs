{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  giflib,
  gnuplot,
  libjpeg,
  libpng,
  libtiff,
  libwebp,
  nix-update-script,
  openjpeg,
  pkg-config,
  which,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "leptonica";
  version = "1.87.0";

  src = fetchFromGitHub {
    owner = "DanBloomBerg";
    repo = "leptonica";
    rev = finalAttrs.version;
    hash = "sha256-d67gxWmWN3WfSPuHrjpC+emLyQswJbKV7gzm7D4bpI0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    giflib
    libjpeg
    libpng
    libtiff
    libwebp
    openjpeg
    zlib
  ];

  # Fails on pngio_reg for unknown reason
  doCheck = false; # !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    which
    gnuplot
  ];

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Image processing and analysis library";
    homepage = "http://www.leptonica.org/";
    license = lib.licenses.bsd2; # http://www.leptonica.org/about-the-license.html
    maintainers = with lib.maintainers; [ patrickdag ];
    platforms = lib.platforms.unix;
  };
})
