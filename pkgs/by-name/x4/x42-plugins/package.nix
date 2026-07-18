{
  lib,
  stdenv,
  fetchurl,
  cairo,
  fftwFloat,
  freefont_ttf,
  ftgl,
  libGLU,
  libjack2,
  libltc,
  libsamplerate,
  libsndfile,
  lv2,
  pango,
  pkg-config,
  zita-convolver,
}:

stdenv.mkDerivation rec {
  pname = "x42-plugins";
  version = "20260420";

  src = fetchurl {
    url = "https://gareus.org/misc/x42-plugins/${pname}-${version}.tar.xz";
    hash = "sha256-wBl+lp2ZcVohlukjuOwhAaoYnEx/D9FktMW9kjmwflE=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libGLU
    ftgl
    freefont_ttf
    libjack2
    libltc
    libsndfile
    libsamplerate
    lv2
    cairo
    pango
    fftwFloat
    zita-convolver
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "FONTFILE=${freefont_ttf}/share/fonts/truetype/FreeSansBold.ttf"
  ];

  enableParallelBuilding = true;

  patchPhase = ''
    patchShebangs ./stepseq.lv2/gridgen.sh
    patchShebangs ./matrixmixer.lv2/genttl.sh
    patchShebangs ./matrixmixer.lv2/genhead.sh
  '';

  # Don't remove this. The default fails with 'do not know how to unpack source archive'
  # every now and then on Hydra. No idea why.
  unpackPhase = ''
    tar xf $src
    sourceRoot=$(echo x42-plugins-*)
    chmod -R u+w $sourceRoot
  '';

  meta = {
    description = "Collection of LV2 plugins by Robin Gareus";
    homepage = "https://github.com/x42/x42-plugins";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      magnetophon
    ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
