{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  gtk3,
  intltool,
  libofx,
  libsoup_3,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "homebank";
  version = "5.10.2";

  src = fetchurl {
    url = "https://www.gethomebank.org/public/sources/homebank-${finalAttrs.version}.tar.gz";
    hash = "sha256-8L6v4H6iIVXI+OJneY1usF1uAV1WYLlvs0/eylprxMc=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    intltool
  ];

  buildInputs = [
    gtk3
    libofx
    libsoup_3
    adwaita-icon-theme
  ];

  meta = {
    description = "Free, easy, personal accounting for everyone";
    homepage = "https://www.gethomebank.org";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pSub
      frlan
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "homebank";
  };
})
