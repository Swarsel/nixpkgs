{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ctestCheckHook,
  expat,
  lerc,
  libGLU,
  libdeflate,
  libunarr,
  libwebp,
  pipewire,
  pkg-config,
  qt6Packages,
  qtwebapp,
  xz,
  onlyServer ? false,
}:
let
  qtPackages = qt6Packages;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "yacreader";
  version = "10.0.0";

  src = fetchFromGitHub {
    owner = "YACReader";
    repo = "yacreader";
    tag = finalAttrs.version;
    hash = "sha256-nJ4S4ej/I+ifDNa3CPpusFpDsEwZwYDt0JLaebptjuU=";
  };

  patches = [
    # Devendor qtwebapp, use pkg-config instead
    ./qtwebapp-devendor.patch
  ];

  # Ensure devendor works
  postPatch = ''
    rm -rf third_party/QtWebApp
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    qtPackages.wrapQtAppsHook
  ];

  buildInputs = [
    libGLU
    libunarr
    expat
    libdeflate
    lerc
    xz
    libwebp
    qtwebapp
    qtPackages.qtbase
    qtPackages.qttools
    qtPackages.qtmultimedia
    qtPackages.qtspeech
    qtPackages.poppler
    qtPackages.qt5compat
  ];

  cmakeFlags = [
    # force unarr backend on all platforms
    (lib.cmakeBool "BUILD_SERVER_STANDALONE" onlyServer)
    (lib.cmakeFeature "PDF_BACKEND" "poppler")
    (lib.cmakeFeature "DECOMPRESSION_BACKEND" "unarr")
  ];

  # Pipewire is dlopen'd, so we must tell it where to look
  preConfigure = ''
    qtWrapperArgs+=("--prefix" "LD_LIBRARY_PATH" ":" "${lib.makeLibraryPath [ pipewire ]}")
  '';

  doCheck = true;

  nativeCheckInputs = [
    ctestCheckHook
  ];

  # custom Darwin install instructions taken from the upstream compileOSX.sh script
  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p "$out"/Applications

    cp -r YACReader/YACReader.app "$out"/Applications/
    cp -r YACReaderLibrary/YACReaderLibrary.app "$out"/Applications/
    cp -r YACReaderLibraryServer/YACReaderLibraryServer.app "$out"/Applications/

    cp -r release/server "$out"/Applications/YACReaderLibrary.app/Contents/MacOS/
    cp -r release/server "$out"/Applications/YACReaderLibraryServer.app/Contents/MacOS/
    cp -r release/languages "$out"/Applications/YACReader.app/Contents/MacOS/
    cp -r release/languages "$out"/Applications/YACReaderLibrary.app/Contents/MacOS/
    cp -r release/languages "$out"/Applications/YACReaderLibraryServer.app/Contents/MacOS/

    makeWrapper "$out"/Applications/YACReader.app/Contents/MacOS/YACReader "$out/bin/YACReader"
    makeWrapper "$out"/Applications/YACReaderLibrary.app/Contents/MacOS/YACReaderLibrary "$out/bin/YACReaderLibrary"
    makeWrapper "$out"/Applications/YACReaderLibraryServer.app/Contents/MacOS/YACReaderLibraryServer "$out/bin/YACReaderLibraryServer"

    runHook postInstall
  '';

  __structuredAttrs = true;

  meta = {
    description = "Comic reader for cross-platform reading and managing your digital comic collection";
    homepage = "https://www.yacreader.com";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    mainProgram = "YACReader";
  };
})
