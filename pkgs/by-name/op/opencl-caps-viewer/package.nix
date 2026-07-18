{
  lib,
  stdenv,
  fetchFromGitHub,
  libsForQt5,
  ocl-icd,
  opencl-headers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencl-caps-viewer";
  version = "1.30";

  src = fetchFromGitHub {
    owner = "SaschaWillems";
    repo = "OpenCLCapsViewer";
    tag = finalAttrs.version;
    hash = "sha256-fQDBo1/mT6Re6FgdB8ImDRAIsnstnzQsz04cRGgjM/M=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # Fix installation paths
    substituteInPlace OpenCLCapsViewer.pro \
      --replace-fail "target.path = /usr/bin" "target.path = /bin/" \
      --replace-fail "desktop.path = /usr/share/applications" "desktop.path = /share/applications" \
      --replace-fail "icon.path = /usr/share/icons/hicolor/256x256/apps/" "icon.path = /share/icons/hicolor/256x256/apps/" \
      --replace-fail 'else: unix:!android: target.path = /opt/$${TARGET}/bin' ""
  '';

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    ocl-icd
    opencl-headers
    libsForQt5.qtx11extras
    libsForQt5.qtbase
  ];

  postInstall = ''
    cp Resources/icon.png $out/share/icons/hicolor/256x256/apps/openclCapsViewer.png
  '';

  enableParallelBuilding = true;
  installFlags = [ "INSTALL_ROOT=${placeholder "out"}" ];

  qmakeFlags = [
    "OpenCLCapsViewer.pro"
    "CONFIG+=x11"
  ];

  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${ocl-icd}/lib"
  ];

  meta = {
    description = "OpenCL hardware capability viewer";

    longDescription = ''
      Client application to display hardware implementation details for devices supporting the OpenCL API by Khronos.
      The hardware reports can be submitted to a public online database that allows comparing different devices, browsing available features, extensions, formats, etc.
    '';

    homepage = "https://opencl.gpuinfo.org/";
    changelog = "https://github.com/SaschaWillems/OpenCLCapsViewer/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ andrewgigena ];
    platforms = lib.platforms.linux;
    mainProgram = "OpenCLCapsViewer";
  };
})
