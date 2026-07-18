{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  fcitx5,
  gettext,
  kdePackages,
  libime,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "fcitx5-table-extra";
  version = "5.1.12";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = pname;
    rev = version;
    hash = "sha256-PNljzjvT5WWoEPH7HbOcO9lDRkZHqiNXbaCifBKw5LI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    gettext
    libime
    fcitx5
  ];

  buildInputs = [
    boost
  ];

  meta = {
    description = "Extra table for Fcitx, including Boshiamy, Zhengma, Cangjie, and Quick";
    homepage = "https://github.com/fcitx/fcitx5-table-extra";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ poscat ];
    platforms = lib.platforms.linux;
  };
}
