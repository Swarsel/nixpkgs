{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  extra-cmake-modules,
  fcitx5,
  fcitx5-qt,
  isocodes,
  kcmutils,
  kcoreaddons,
  kdeclarative,
  kitemviews,
  kwidgetsaddons,
  libxkbfile,
  pkg-config,
  qtbase,
  qtdeclarative,
  qtsvg,
  qtwayland,
  wrapQtAppsHook,
  xkeyboard-config,
  kcmSupport ? true,
  kirigami ? null,
  libplasma ? null,
}:

stdenv.mkDerivation rec {
  pname = "fcitx5-configtool";
  version = "5.1.14";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = pname;
    rev = version;
    hash = "sha256-+lpJlGaVGTcZpoGvcHAsb5N5M4Y3McV4GSZpSwZxX3Y=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    fcitx5
    fcitx5-qt
    qtbase
    qtsvg
    qtwayland
    kitemviews
    kwidgetsaddons
    isocodes
    xkeyboard-config
    libxkbfile
  ]
  ++ lib.optionals kcmSupport [
    qtdeclarative
    kcoreaddons
    kdeclarative
    kcmutils
    libplasma
    kirigami
  ];

  cmakeFlags = [
    (lib.cmakeBool "KDE_INSTALL_USE_QT_SYS_PATHS" true)
    (lib.cmakeBool "ENABLE_KCM" kcmSupport)
  ];

  meta = {
    description = "Configuration Tool for Fcitx5";
    homepage = "https://github.com/fcitx/fcitx5-configtool";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ poscat ];
    platforms = lib.platforms.linux;
    mainProgram = "fcitx5-config-qt";
  };
}
