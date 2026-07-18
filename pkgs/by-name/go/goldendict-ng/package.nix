{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cmake,
  fmt,
  hunspell,
  libeb,
  libiconv,
  libvorbis,
  libxtst,
  libzim,
  lzo,
  opencc,
  pkg-config,
  qt6,
  tomlplusplus,
  wrapGAppsHook3,
  xapian,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "goldendict-ng";
  version = "26.6.2";

  src = fetchFromGitHub {
    owner = "xiaoyifang";
    repo = "goldendict-ng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2K0I6uYJtqRw0JbvNbbmIjzxzn6l7tzDU1d9Lo49cYs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
    qt6.qtwebengine
    qt6.qt5compat
    qt6.qtmultimedia
    qt6.qtwayland
    libvorbis
    tomlplusplus
    fmt
    hunspell
    xz
    lzo
    libxtst
    bzip2
    libiconv
    opencc
    libeb
    xapian
    libzim
  ];

  cmakeFlags = [
    "-DWITH_XAPIAN=ON"
    "-DWITH_ZIM=ON"
    "-DWITH_FFMPEG_PLAYER=OFF"
    "-DWITH_EPWING_SUPPORT=ON"
    "-DUSE_SYSTEM_FMT=ON"
    "-DUSE_SYSTEM_TOML=ON"
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # Prevent double wrapping of wrapQtApps and wrapGApps
  dontWrapGApps = true;

  meta = {
    description = "Advanced multi-dictionary lookup program";
    homepage = "https://xiaoyifang.github.io/goldendict-ng/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      slbtty
      michojel
      linsui
    ];

    platforms = lib.platforms.linux;
    mainProgram = "goldendict";
  };
})
