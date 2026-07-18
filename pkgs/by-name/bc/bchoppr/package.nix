{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cpio,
  libsndfile,
  libx11,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bchoppr";
  version = "1.12.8";

  src = fetchFromGitHub {
    owner = "sjaehn";
    repo = "bchoppr";
    tag = finalAttrs.version;
    hash = "sha256-zbRriQ5pcoQ1Hi1gux2kM260kGxFzng251og/niUiLQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    cairo
    libx11
    lv2
    libsndfile
    cpio
  ];

  enableParallelBuilding = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Audio stream chopping LV2 plugin";
    homepage = "https://github.com/sjaehn/BChoppr";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
