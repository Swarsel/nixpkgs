{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk2,
  hamlib_4,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "grig";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "fillods";
    repo = "grig";
    rev = "GRIG-${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    sha256 = "sha256-OgIgHW9NMW/xSSti3naIR8AQWUtNSv5bYdOcObStBlM=";
  };

  patches = [
    # https://github.com/fillods/grig/issues/22
    ./0001-Fix-grig-for-hamlib-4.6.2.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    hamlib_4
    gtk2
  ];

  meta = {
    description = "Simple Ham Radio control (CAT) program based on Hamlib";

    longDescription = ''
      Grig is a graphical user interface for the Ham Radio Control Libraries.
      It is intended to be simple and generic, presenting the user with the
      same interface regardless of which radio they use.
    '';

    homepage = "https://groundstation.sourceforge.net/grig/";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      mafo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "grig";
  };
})
