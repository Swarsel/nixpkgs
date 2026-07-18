{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  fftw,
  fftwFloat,
  gtk3,
  intltool,
  json_c,
  libjack2,
  libpulseaudio,
  pkg-config,
  wrapGAppsHook3,
  jackSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lingot";
  version = "1.1.1";

  src = fetchurl {
    url = "mirror://savannah/lingot/lingot-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-xPl+SWo2ZscHhtE25vLMxeijgT6wjNo1ys1+sNFvTVY=";
  };

  nativeBuildInputs = [
    pkg-config
    intltool
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    alsa-lib
    libpulseaudio
    fftw
    fftwFloat
    json_c
  ]
  ++ lib.optional jackSupport libjack2;

  configureFlags = lib.optional (!jackSupport) "--disable-jack";

  meta = {
    description = "Not a Guitar-Only tuner";
    homepage = "https://www.nongnu.org/lingot/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "lingot";
  };
})
