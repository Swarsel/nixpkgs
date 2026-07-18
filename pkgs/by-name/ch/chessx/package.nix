{
  lib,
  stdenv,
  fetchurl,
  libsForQt5,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chessx";
  version = "1.6.2";

  src = fetchurl {
    url = "mirror://sourceforge/chessx/chessx-${finalAttrs.version}.tgz";
    hash = "sha256-uwkdhJywLWMJl4/ihMnxqFwnTzUSL+kca5wwiabiD4A=";
  };

  nativeBuildInputs = [
    pkg-config
  ]
  ++ (with libsForQt5; [
    qmake
    wrapQtAppsHook
  ]);

  buildInputs = [
    zlib
  ]
  ++ (with libsForQt5; [
    qtbase
    qtmultimedia
    qtsvg
    qttools
  ]);

  installPhase = ''
    runHook preInstall
    install -Dm555 release/chessx -t "$out/bin"
    install -Dm444 unix/chessx.desktop -t "$out/share/applications"
    runHook postInstall
  '';

  enableParallelBuilding = true;

  # Fails to start on Native Wayland.
  # See https://sourceforge.net/p/chessx/bugs/299/
  qtWrapperArgs = [
    "--set"
    "QT_QPA_PLATFORM"
    "xcb"
  ];

  meta = {
    description = "Browse and analyse chess games";
    homepage = "https://chessx.sourceforge.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ luispedro ];
    platforms = lib.platforms.linux;
    mainProgram = "chessx";
  };
})
