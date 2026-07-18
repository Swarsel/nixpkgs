{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpxlab";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "BourgeoisLab";
    repo = "GPXLab";
    rev = "v${finalAttrs.version}";
    sha256 = "080vnwcciqblfrbfyz9gjhl2lqw1hkdpbgr5qfrlyglkd4ynjd84";
  };

  nativeBuildInputs = [
    qt5.qmake
    qt5.qttools
    qt5.wrapQtAppsHook
  ];

  preConfigure = ''
    lrelease GPXLab/locale/*.ts
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv GPXLab/GPXLab.app $out/Applications

    mkdir -p $out/bin
    ln -s $out/Applications/GPXLab.app/Contents/MacOS/GPXLab $out/bin/gpxlab
  '';

  meta = {
    description = "Program to show and manipulate GPS tracks";

    longDescription = ''
      GPXLab is an application to display and manage GPS tracks
      previously recorded with a GPS tracker.
    '';

    homepage = "https://github.com/BourgeoisLab/GPXLab";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "gpxlab";
  };
})
