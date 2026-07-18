{
  lib,
  stdenv,
  fetchFromSourcehut,
  libsForQt5,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bfcal";
  version = "1.0.1";

  src = fetchFromSourcehut {
    owner = "~bitfehler";
    repo = "bfcal";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-5xyBU+0XUNFUGgvw7U8YE64zncw6SvPmbJhc1LY2u/g=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
  ];

  meta = {
    description = "Quickly display a calendar";
    homepage = "https://git.sr.ht/~bitfehler/bfcal";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ laalsaas ];
    platforms = libsForQt5.qtbase.meta.platforms;
    mainProgram = "bfcal";
  };
})
