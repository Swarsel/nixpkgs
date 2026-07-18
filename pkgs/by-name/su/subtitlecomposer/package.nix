{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  ffmpeg_7,
  kdePackages,
  openal,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "subtitlecomposer";
  version = "0.8.2";

  src = fetchFromGitLab {
    owner = "multimedia";
    repo = "subtitlecomposer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zGbI960NerlOEUvhOLm+lEJdbhj8VFUfm8pkOYGRcGw=";
    domain = "invent.kde.org";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    ffmpeg_7
    openal
    qt6.qt5compat
  ]
  ++ (with kdePackages; [
    kcodecs
    kconfig
    kconfigwidgets
    kcoreaddons
    ki18n
    kio
    ktextwidgets
    kwidgetsaddons
    kxmlgui
    sonnet
  ]);

  cmakeFlags = [
    "-DQT_MAJOR_VERSION=6"
    "-DQT_FIND_PRIVATE_MODULES=ON"
  ];

  meta = {
    description = "Open source text-based subtitle editor";

    longDescription = ''
      An open source text-based subtitle editor that supports basic and
      advanced editing operations, aiming to become an improved version of
      Subtitle Workshop for every platform supported by Plasma Frameworks.
    '';

    homepage = "https://apps.kde.org/subtitlecomposer";
    changelog = "https://invent.kde.org/multimedia/subtitlecomposer/-/blob/master/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ kugland ];
    platforms = with lib.platforms; linux ++ freebsd ++ windows;
    mainProgram = "subtitlecomposer";
  };
})
