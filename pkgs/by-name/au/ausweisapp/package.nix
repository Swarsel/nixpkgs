{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  llhttp,
  pcsclite,
  pkg-config,
  qt6,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ausweisapp";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "Governikus";
    repo = "AusweisApp";
    rev = finalAttrs.version;
    hash = "sha256-pr41KbejZCOvfXH2uHO5MA/VklSNU38EL6AgznvGqeY=";
  };

  postPatch = ''
    # avoid runtime QML cache to fix GUI loading issues
    substituteInPlace src/ui/qml/CMakeLists.txt src/ui/qml/modules/CMakeLists.txt \
      --replace-fail NO_CACHEGEN ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    llhttp
    pcsclite
    qt6.qtscxml
    qt6.qtsvg
    qt6.qttools
    qt6.qtwayland
    qt6.qtwebsockets
  ];

  env.LANG = "C.UTF-8";

  # The build scripts copy the entire translations directory from Qt
  # which ends up being read-only because it's in the store.
  preBuild = ''
    chmod +w resources/translations
  '';

  passthru = {
    tests.version = testers.testVersion {
      command = "QT_QPA_PLATFORM=offscreen ${finalAttrs.meta.mainProgram} --version";
      package = finalAttrs.finalPackage;
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "Official authentication app for German ID card and residence permit";
    homepage = "https://www.ausweisapp.bund.de/open-source-software";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ b4dm4n ];
    platforms = lib.platforms.linux;
    mainProgram = "AusweisApp";
    downloadPage = "https://github.com/Governikus/AusweisApp/releases";
  };
})
