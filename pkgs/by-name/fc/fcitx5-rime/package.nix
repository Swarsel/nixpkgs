{
  lib,
  stdenv,
  fetchurl,
  cmake,
  fcitx5,
  gettext,
  kdePackages,
  librime,
  pkg-config,
  rime-data,
  symlinkJoin,
  zstd,
  rimeDataPkgs ? [ rime-data ],
}:

stdenv.mkDerivation rec {
  pname = "fcitx5-rime";
  version = "5.1.14";

  src = fetchurl {
    url = "https://download.fcitx-im.org/fcitx5/${pname}/${pname}-${version}.tar.zst";
    hash = "sha256-dHiBH74dTnzabm23TrDAXV/oHSGMqdyBtrf0uyuwjWI=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    gettext
    zstd
  ];

  buildInputs = [
    fcitx5
    librime
  ];

  cmakeFlags = [
    "-DRIME_DATA_DIR=${placeholder "out"}/share/rime-data"
  ];

  postInstall = ''
    cp -r "${rimeDataDrv}/share/rime-data/." $out/share/rime-data/
  '';

  rimeDataDrv = symlinkJoin {
    postBuild = ''
      mkdir -p $out/share/rime-data

      # Ensure default.yaml exists
      [ -e "$out/share/rime-data/default.yaml" ] || touch "$out/share/rime-data/default.yaml"
    '';

    name = "fcitx5-rime-data";
    paths = rimeDataPkgs;
  };

  meta = {
    description = "RIME support for Fcitx5";
    homepage = "https://github.com/fcitx/fcitx5-rime";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ poscat ];
    platforms = lib.platforms.linux;
  };
}
