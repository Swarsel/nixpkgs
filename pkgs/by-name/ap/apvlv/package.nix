{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cmark,
  copyDesktopItems,
  djvulibre,
  fetchpatch,
  freetype,
  ghostscript,
  harfbuzz,
  installShellFiles,
  man,
  mupdf,
  pkg-config,
  poppler,
  qt6,
  qt6Packages,
  tesseract,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apvlv";
  # If you change the version, please also update src.rev accordingly
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "naihe2010";
    repo = "apvlv";
    tag = "v0.7.0-final";
    hash = "sha256-PDqH3nROR16q11dHIkC5+jAiRSIIfp52M8o4IT1BaT0=";
  };

  patches = [
    # Update minimum CMake version, so it works with CMake 4
    (fetchpatch {
      hash = "sha256-OA3Qy+ECUW+Yq1FKiye+y6C01GD1ZLPbdzYK5ofM4Qg=";
      name = "apvlv-cmake-4.patch";
      url = "https://github.com/naihe2010/apvlv/commit/03b9e74173e1b5cbf4451b71bed066f1b58c9c78.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    ghostscript
    installShellFiles
    man
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    cmark
    djvulibre
    # https://github.com/naihe2010/apvlv/blob/03b9e74173e1b5cbf4451b71bed066f1b58c9c78/src/CMakeLists.txt#L158
    harfbuzz
    mupdf
    qt6Packages.poppler
    qt6Packages.quazip
    qt6.qtwebengine
    tesseract
  ];

  cmakeFlags = [
    # Off by default on non-Windows
    "-DAPVLV_WITH_POPPLER=ON"
    # TODO: apvlv built with libreoffice support segfaults, tried
    # - libreoffice-unwrapped in buildInputsto
    # - env.NIX_LDFLAGS = "-L${libreoffice-unwrapped}/lib/libreoffice/program";
    "-DAPVLV_WITH_OFFICE=OFF"
  ];

  env = {
    # UTF-8 locale for translation generation
    LANG = "C.UTF8";
    # accomodate #include <qt6/poppler-qt6.h>…
    NIX_CFLAGS_COMPILE = "-I${qt6Packages.poppler.dev}/include/poppler";
  };

  preBuild = ''
    mkdir -p ../share/doc/apvlv/translations
  '';

  installPhase = ''
    runHook preInstall

    # binary
    mkdir -p $out/bin
    cp src/apvlv $out/bin/apvlv

    # displays pdfStartup.pdf as default pdf entry
    mkdir -p $out/share/doc/apvlv/
    cp ../Startup.pdf $out/share/doc/apvlv/Startup.pdf

    mkdir -p $out/etc
    cp ../apvlvrc.example $out/etc/apvlvrc

    installManPage ../apvlv.1

    runHook postInstall
  '';

  desktopItems = [
    "../apvlv.desktop"
  ];

  passthru = {
    tests.version = testers.testVersion {
      version = "${finalAttrs.version}-rel";
      command = "QT_QPA_PLATFORM=offscreen ${lib.getExe finalAttrs.finalPackage} --version";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "PDF viewer with Vim-like behaviour";

    longDescription = ''
      apvlv is a PDF/DJVU/UMD/TXT Viewer Under Linux/WIN32
      with Vim-like behaviour.
    '';

    homepage = "https://naihe2010.github.io/apvlv/";
    changelog = "https://github.com/naihe2010/apvlv/blob/v${finalAttrs.version}/NEWS";
    license = lib.licenses.lgpl2;

    maintainers = with lib.maintainers; [
      ardumont
      anthonyroussel
    ];

    platforms = lib.platforms.linux;
    mainProgram = "apvlv";
  };
})
