{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  buildPackages,
  cairo,
  cmake,
  enchant,
  expat,
  fribidi,
  gdk-pixbuf,
  gettext,
  isocodes,
  kdePackages,
  libGL,
  libdatrie,
  libselinux,
  libsepol,
  libthai,
  libuuid,
  libxcb-keysyms,
  libxcb-util,
  libxcb-wm,
  libxdmcp,
  libxkbcommon,
  libxkbfile,
  nixosTests,
  nlohmann_json,
  pango,
  pkg-config,
  systemd,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xcb-imdkit,
  xkeyboard_config,
}:
let
  enDictVer = "20121020";
  enDict = fetchurl {
    hash = "sha256-xEpdeEeSXuqeTS0EdI1ELNKN2SmaC1cu99kerE9abOs=";
    url = "https://download.fcitx-im.org/data/en_dict-${enDictVer}.tar.gz";
  };
in
stdenv.mkDerivation rec {
  pname = "fcitx5";
  version = "5.1.21";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = pname;
    rev = version;
    hash = "sha256-IR5mKOsVJ/GPL2czdztLVXGJTNk1JXnWpzmqC/UIwuw=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
    gettext
  ];

  buildInputs = [
    kdePackages.plasma-wayland-protocols
    kdePackages.extra-cmake-modules
    expat
    isocodes
    cairo
    enchant
    pango
    libthai
    libdatrie
    fribidi
    systemd
    gdk-pixbuf
    wayland
    wayland-protocols
    nlohmann_json
    libGL
    libuuid
    libselinux
    libsepol
    libxdmcp
    libxkbcommon
    libxcb-util
    libxcb-wm
    libxcb-keysyms
    xcb-imdkit
    xkeyboard_config
    libxkbfile
  ];

  cmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    (lib.cmakeFeature "CMAKE_CROSSCOMPILING_EMULATOR" (stdenv.hostPlatform.emulator buildPackages))
  ];

  prePatch = ''
    ln -s ${enDict} src/modules/spell/$(stripHash ${enDict})
  '';

  passthru = {
    tests = {
      inherit (nixosTests) fcitx5;
    };

    updateScript = ./update.py;
  };

  meta = {
    description = "Next generation of fcitx";
    homepage = "https://github.com/fcitx/fcitx5";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ poscat ];
    platforms = lib.platforms.linux;
    mainProgram = "fcitx5";
  };
}
