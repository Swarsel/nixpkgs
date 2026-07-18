{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  ffmpeg-headless,
  libsForQt5,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mlv-app";
  version = "1.15";

  src = fetchFromGitHub {
    owner = "ilia3101";
    repo = "MLV-App";
    rev = "QTv${finalAttrs.version}";
    hash = "sha256-boYnIGDowV4yRxdE98U5ngeAwqi5HTRDFh5gVwW/kN8=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-DQkoB+fjshWDLzKouhEQXzpqn78WL+eqo5oTfE9ltEk=";
      url = "https://github.com/ilia3101/MLV-App/commit/b7643b1031955f085ade30e27974ddd889a4641f.patch";
    })
  ];

  postPatch = ''
    substituteInPlace platform/qt/MainWindow.cpp \
      --replace-fail '"ffmpeg"' '"${lib.getExe ffmpeg-headless}"'
  '';

  nativeBuildInputs = [
    libsForQt5.wrapQtAppsHook
    libsForQt5.qmake
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    libsForQt5.qtmultimedia
    libsForQt5.qtbase
  ];

  preConfigure = ''
    cd platform/qt/
  '';

  installPhase = ''
    runHook preInstall
    install -Dm555 -t $out/bin                mlvapp
    install -Dm444 -t $out/share/applications mlvapp.desktop
    install -Dm444 -t $out/share/icons/hicolor/512x512/apps RetinaIMG/MLVAPP.png
    runHook postInstall
  '';

  preFixup = ''
    wrapQtApp "$out/bin/mlvapp"
  '';

  dontWrapQtApps = true;
  qmakeFlags = [ "MLVApp.pro" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "All in one MLV processing app that is pretty great";
    homepage = "https://mlv.app";
    changelog = "https://github.com/ilia3101/MLV-App/releases/tag/QTv${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "mlvapp";
    downloadPage = "https://github.com/ilia3101/MLV-App";
  };
})
