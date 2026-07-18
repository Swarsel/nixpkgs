{
  lib,
  stdenv,
  cmake,
  fetchgit,
  json_c,
  libnl-tiny,
  libubox,
  pkg-config,
  ubus,
  uci,
  ucode,
  udebug,
}:

stdenv.mkDerivation {
  pname = "netifd";
  version = "0-unstable-2026-02-26";

  src = fetchgit {
    url = "https://git.openwrt.org/project/netifd.git";
    rev = "69a5afc9713adf31edbf3228a7a372ada7bba449";
    hash = "sha256-R/ryiFiKNM7zrIgzlalAK0lNJF/vzWL56E9CbptJtmI=";
  };

  postPatch = ''
    # by default this assumes the build directory is the source directory
    # since we let cmake build in it's own build directory, we need to use
    # $PWD (which at the time of this script being run is the directory with the source code)
    # to adjust the paths
    sed "s|./make_ethtool_modes_h.sh|$PWD/make_ethtool_modes_h.sh|g" -i CMakeLists.txt
    sed "s|./ethtool-modes.h|$PWD/ethtool-modes.h|g" -i CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libnl-tiny
    libubox
    uci
    ubus
    ucode
    json_c
    udebug
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LIBNL_LIBS" "-lnl-tiny")
  ];

  env.NIX_CFLAGS_COMPILE = "-I${libnl-tiny}/include/libnl-tiny";

  meta = {
    description = "OpenWrt Network interface configuration daemon";
    homepage = "https://git.openwrt.org/?p=project/netifd.git;a=summary";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ mkg20001 ];
    platforms = lib.platforms.linux;
    mainProgram = "netifd";
  };
}
