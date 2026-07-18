{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  qt6,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpxsee";
  version = "16.9";

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = "GPXSee";
    tag = finalAttrs.version;
    hash = "sha256-pb5HsmGIiC2A5IjGYm+M636J7vM8LP9LFGINkSaSSj4=";
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.qttools
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtpositioning
    qt6.qtserialport
    qt6.qtsvg
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    qt6.qt5compat
  ];

  preConfigure = ''
    lrelease lang/*.ts
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv GPXSee.app $out/Applications
    mkdir -p $out/bin
    ln -s $out/Applications/GPXSee.app/Contents/MacOS/GPXSee $out/bin/gpxsee
  '';

  preFixup = ''
    qtWrapperArgs+=(''${gappsWrapperArgs[@]})
  '';

  dontWrapGApps = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "GPS log file viewer and analyzer";

    longDescription = ''
      GPXSee is a Qt-based GPS log file viewer and analyzer that supports
      all common GPS log file formats.
    '';

    homepage = "https://www.gpxsee.org/";
    changelog = "https://github.com/tumic0/GPXSee/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      womfoo
      sikmir
    ];

    platforms = lib.platforms.unix;
    mainProgram = "gpxsee";
  };
})
