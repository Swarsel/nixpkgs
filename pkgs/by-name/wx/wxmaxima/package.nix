{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  cmake,
  gettext,
  glib,
  maxima,
  wrapGAppsHook3,
  # Supports also wxwidgets_3_2
  wxwidgets_3_3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wxmaxima";
  version = "26.07.0";

  src = fetchFromGitHub {
    owner = "wxMaxima-developers";
    repo = "wxmaxima";
    rev = "Version-${finalAttrs.version}";
    hash = "sha256-rrXYSW3PU4CvtmBH0dU/sBwe1sVel9IkI89HTj0YEqc=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    cmake
    gettext
  ];

  buildInputs = [
    wxwidgets_3_3
    maxima
    # So it won't embed svg files into headers.
    adwaita-icon-theme
    # So it won't crash under Sway.
    glib
  ];

  cmakeFlags = [
    "-DwxWidgets_LIBRARIES=${wxwidgets_3_3}/lib"
  ];

  preConfigure = ''
    gappsWrapperArgs+=(--prefix PATH ":" ${maxima}/bin)
  '';

  meta = {
    description = "Cross platform GUI for the computer algebra system Maxima";
    homepage = "https://wxmaxima-developers.github.io/wxmaxima/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux;
    mainProgram = "wxmaxima";
  };
})
