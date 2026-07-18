{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  flex,
  gitUpdater,
  libiconv,
  libjpeg,
  libpng,
  libwebp,
  meson,
  ninja,
  pkg-config,
  qt5,
  qt6,
  testers,
  zlib,
  withQt5 ? false,
  withQt6 ? false,
}:

assert !(withQt5 && withQt6);

let
  qt = if withQt5 then qt5 else qt6;
  withGUI = withQt5 || withQt6;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "alice-tools" + lib.optionalString withGUI "-qt${lib.versions.major qt.qtbase.version}";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "nunuhara";
    repo = "alice-tools";
    tag = finalAttrs.version;
    hash = "sha256-DazWnBeI5XShkIx41GFZLP3BbE0O8T9uflvKIZUXCHo=";
    fetchSubmodules = true;
  };

  postPatch = lib.optionalString (withGUI && withQt6) ''
    # Use Meson's Qt6 module
    substituteInPlace src/meson.build \
      --replace qt5 qt6

    # For some reason Meson uses QMake instead of pkg-config detection method for Qt6 on Darwin, which gives wrong search paths for tools
    export PATH=${qt.qtbase.dev}/libexec:$PATH
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    bison
    flex
  ]
  ++ lib.optionals withGUI [
    qt.wrapQtAppsHook
  ];

  buildInputs = [
    libiconv
    libpng
    libjpeg
    libwebp
    zlib
  ]
  ++ lib.optionals withGUI [
    qt.qtbase
  ];

  mesonFlags = lib.optionals (withGUI && withQt6) [
    # Qt6 requires at least C++17, project uses compiler's default, default too old on Darwin & aarch64-linux
    "-Dcpp_std=c++17"
  ];

  # Default install step only installs a static library of a build dependency
  installPhase = ''
    runHook preInstall

    install -Dm755 src/alice $out/bin/alice
  ''
  + lib.optionalString withGUI ''
    install -Dm755 src/galice $out/bin/galice
    wrapQtApp $out/bin/galice
  ''
  + ''

    runHook postInstall
  '';

  dontWrapQtApps = true;

  passthru = {
    tests.version = testers.testVersion {
      command =
        lib.optionalString withGUI "env QT_QPA_PLATFORM=minimal "
        + "${lib.getExe finalAttrs.finalPackage} --version";

      package = finalAttrs.finalPackage;
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "Tools for extracting/editing files from AliceSoft games";
    homepage = "https://github.com/nunuhara/alice-tools";
    changelog = "https://github.com/nunuhara/alice-tools/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.all;
    mainProgram = if withGUI then "galice" else "alice";
  };
})
