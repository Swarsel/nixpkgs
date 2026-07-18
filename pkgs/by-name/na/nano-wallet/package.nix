{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  fetchpatch,
  libGL,
  libsForQt5,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {

  pname = "nano-wallet";
  version = "28.2";

  src = fetchFromGitHub {
    owner = "nanocurrency";
    repo = "nano-node";
    tag = "V${finalAttrs.version}";
    hash = "sha256-Wo1Gd6dOnCoPiGmuJQhZmKKSg7LrKpfdvLNNKBYTUWI=";
    fetchSubmodules = true;
  };

  patches = [
    # fix issue with <algorithm> include
    (fetchpatch {
      hash = "sha256-IpC4yaIbJzQWYIC0QGXYQ345g6JnD2+xZG30qAQ1ubo=";
      url = "https://github.com/nanocurrency/nano-node/commit/1835a04dbbd1f6970649d7f72c454831432dd01f.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    boost
    libGL
    libsForQt5.qtbase
  ];

  cmakeFlags =
    let
      options = {
        BOOST_ROOT = boost;
        NANO_SHARED_BOOST = "ON";
        PYTHON_EXECUTABLE = "${python3.interpreter}";
        Qt5Core_DIR = "${libsForQt5.qtbase.dev}/lib/cmake/Qt5Core";
        Qt5Gui_INCLUDE_DIRS = "${libsForQt5.qtbase.dev}/include/QtGui";
        Qt5Widgets_INCLUDE_DIRS = "${libsForQt5.qtbase.dev}/include/QtWidgets";
        Qt5_DIR = "${libsForQt5.qtbase.dev}/lib/cmake/Qt5";
        RAIBLOCKS_GUI = "ON";
        RAIBLOCKS_TEST = "ON";
      };
      optionToFlag = name: value: "-D${name}=${value}";
    in
    lib.mapAttrsToList optionToFlag options;

  makeFlags = [ "nano_wallet" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  checkPhase = ''
    runHook preCheck
    ./core_test
    runHook postCheck
  '';

  meta = {
    description = "Wallet for Nano cryptocurrency";
    homepage = "https://nano.org/en/wallet/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ jluttine ];
    # Fails on Darwin. See:
    # https://github.com/NixOS/nixpkgs/pull/39295#issuecomment-386800962
    platforms = lib.platforms.linux;
  };
})
