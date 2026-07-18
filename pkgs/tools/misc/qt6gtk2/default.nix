{
  lib,
  stdenv,
  fetchFromGitLab,
  gtk2,
  nix-update-script,
  pkg-config,
  qmake,
  qtbase,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qt6gtk2";
  version = "0.6";

  src = fetchFromGitLab {
    owner = "trialuser";
    repo = "qt6gtk2";
    tag = finalAttrs.version;
    hash = "sha256-RJybIm0HllnYaPfsnci+9ZCGvvL9F2MC7dDbiK+L7bU=";
    domain = "opencode.net";
  };

  nativeBuildInputs = [
    pkg-config
    qmake
  ];

  buildInputs = [
    gtk2
    qtbase
  ];

  dontWrapQtApps = true;

  qmakeFlags = [
    "PLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GTK+2.0 integration plugins for Qt6";
    homepage = "https://www.opencode.net/trialuser/qt6gtk2";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.misterio77 ];
    platforms = lib.platforms.linux;
  };
})
