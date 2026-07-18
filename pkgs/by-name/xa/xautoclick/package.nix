{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  fltk,
  glib,
  gtk3,
  libevdev,
  libxtst,
  pkg-config,
  qt5,
  wrapGAppsHook3,
  fltkSupport ? true,
  gtkSupport ? true,
  qtSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xautoclick";
  version = "0.34";

  src = fetchFromGitHub {
    owner = "qarkai";
    repo = "xautoclick";
    rev = "v${finalAttrs.version}";
    sha256 = "GN3zI5LQnVmRC0KWffzUTHKrxcqnstiL55hopwTTwpE=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-4ovcaVrXQqFZX85SnewtfjZpipcGTw52ZrTkT6iWZQM=";
      name = "bump-cmake-required-version.patch";
      url = "https://github.com/qarkai/xautoclick/commit/a6cd4058fa7d8579bf4ada3f48441f333fca9dab.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libevdev
    libxtst
  ]
  ++ lib.optionals gtkSupport [
    gtk3
    glib
    wrapGAppsHook3
  ]
  ++ lib.optionals fltkSupport [ fltk ]
  ++ lib.optionals qtSupport [
    qt5.qtbase
    qt5.wrapQtAppsHook
  ];

  meta = {
    description = "Autoclicker application, which enables you to automatically click the left mousebutton";
    homepage = "https://github.com/qarkai/xautoclick";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})
