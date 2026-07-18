{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  meson,
  ninja,
  pkg-config,
  qt6,
}:

let
  libopenrazer = stdenv.mkDerivation (finalAttrs: {
    pname = "libopenrazer";
    version = "0.4.0";

    src = fetchFromGitHub {
      owner = "z3ntu";
      repo = "libopenrazer";
      tag = "v${finalAttrs.version}";
      hash = "sha256-2RH4mevJS5HaEkb5lDNwoMaMNACXJGUVA5RWSYSsakI=";
    };

    nativeBuildInputs = [
      pkg-config
      meson
      ninja
    ];

    buildInputs = [
      qt6.qtbase
      qt6.qttools
    ];

    dontWrapQtApps = true;

    meta = {
      description = "Qt wrapper around the D-Bus API from OpenRazer";
      homepage = "https://github.com/z3ntu/libopenrazer";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
    };
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "razergenie";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "z3ntu";
    repo = "RazerGenie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TxW6IUHmEaNdJPeEGwo57a3EGH6MMyitVTmzStVmZjc=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    libopenrazer
  ];

  postUnpack = "ln -s ${libopenrazer} libopenrazer";

  meta = {
    description = "Qt application for configuring your Razer devices under GNU/Linux";
    homepage = "https://github.com/z3ntu/RazerGenie";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "razergenie";
  };
})
