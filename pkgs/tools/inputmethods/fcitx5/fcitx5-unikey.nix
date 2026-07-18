{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fcitx5,
  fcitx5-qt,
  gettext,
  kdePackages,
  pkg-config,
  qtbase,
}:

stdenv.mkDerivation rec {
  pname = "fcitx5-unikey";
  version = "5.1.11";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = "fcitx5-unikey";
    rev = version;
    hash = "sha256-ekGZreXoc/8yM2+PNsSLcMIsSxbRmkCQcknAZtNC3kM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    gettext # msgfmt
  ];

  buildInputs = [
    qtbase
    fcitx5
    fcitx5-qt
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Unikey engine support for Fcitx5";
    homepage = "https://github.com/fcitx/fcitx5-unikey";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ berberman ];
    platforms = lib.platforms.linux;
  };
}
