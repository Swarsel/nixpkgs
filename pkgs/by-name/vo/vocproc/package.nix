{
  lib,
  stdenv,
  fetchzip,
  fftw,
  gtkmm2,
  lv2,
  lv2-cpp-tools,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vocproc";
  version = "0.2.1";

  src = fetchzip {
    url = "https://hyperglitch.com/files/vocproc/vocproc-${finalAttrs.version}.default.tar.gz";
    sha256 = "07a1scyz14mg2jdbw6fpv4qg91zsw61qqii64n9qbnny9d5pn8n2";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    lv2
    fftw
    lv2-cpp-tools
    gtkmm2
  ];

  makeFlags = [
    "INSTALL_DIR=$(out)/lib/lv2"
  ];

  meta = {
    description = "LV2 plugin for pitch shifting (with or without formant correction), vocoding, automatic pitch correction and harmonizing of singing voice (harmonizer)";
    homepage = "https://hyperglitch.com/dev/VocProc";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.michalrus ];
    platforms = lib.platforms.linux;
  };
})
