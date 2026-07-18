{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  boost,
  cmake,
  curl,
  fcitx5,
  fcitx5-lua,
  fcitx5-qt,
  fetchpatch,
  fmt,
  gettext,
  kdePackages,
  libime,
  opencc,
  pkg-config,
  qtbase,
  qtwebengine,
  luaSupport ? true,
}:

let
  pyStrokeVer = "20250329";
  pyStroke = fetchurl {
    hash = "sha256-wafKciXTYUq4M1P8gnUDAGqYBEd2IBj1N2BCXXtTA6Y=";
    url = "http://download.fcitx-im.org/data/py_stroke-${pyStrokeVer}.tar.gz";
  };
  pyTableVer = "20121124";
  pyTable = fetchurl {
    hash = "sha256-QhRqyX3mwT1V+eme2HORX0xmc56cEVMqNFVrrfl5LAQ=";
    url = "http://download.fcitx-im.org/data/py_table-${pyTableVer}.tar.gz";
  };
in

stdenv.mkDerivation rec {
  pname = "fcitx5-chinese-addons";
  version = "5.1.12";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = pname;
    rev = version;
    hash = "sha256-bAx5m+tU8hT1WdaLChpQV3J0l+QJzDLzMEPTgjEGCuw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    gettext
    fcitx5-lua
  ];

  buildInputs = [
    boost
    fcitx5
    fcitx5-qt
    libime
    curl
    opencc
    qtwebengine
    fmt
    qtbase
  ]
  ++ lib.optional luaSupport fcitx5-lua;

  dontWrapQtApps = true;

  prePatch = ''
    ln -s ${pyStroke} modules/pinyinhelper/$(stripHash ${pyStroke})
    ln -s ${pyTable} modules/pinyinhelper/$(stripHash ${pyTable})
  '';

  meta = {
    description = "Addons related to Chinese, including IME previous bundled inside fcitx4";
    homepage = "https://github.com/fcitx/fcitx5-chinese-addons";

    license = with lib.licenses; [
      gpl2Plus
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [ poscat ];
    platforms = lib.platforms.linux;
    mainProgram = "scel2org5";
  };
}
