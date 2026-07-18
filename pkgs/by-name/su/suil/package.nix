{
  lib,
  stdenv,
  fetchFromGitLab,
  doxygen,
  gtk2,
  gtk3,
  # runtime
  lv2,
  meson,
  ninja,
  # build time
  pkg-config,
  python3Packages,
  qt5,
  sphinx,
  sphinxygen,
  # options
  withGtk2 ? false,
  withGtk3 ? true,
  withQt5 ? true,
  withX11 ? !stdenv.hostPlatform.isDarwin,
}:

let
  inherit (lib) mesonEnable;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "suil";
  version = "0.10.20";

  src = fetchFromGitLab {
    owner = "lv2";
    repo = "suil";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rP8tq+zmHrAZeuNttakPPfraFXNvnwqbhtt+LtTNV/k=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    sphinxygen
    doxygen
    sphinx
    python3Packages.sphinx-lv2-theme
  ];

  buildInputs = [
    lv2
  ]
  ++ lib.optionals withGtk2 [ gtk2 ]
  ++ lib.optionals withGtk3 [ gtk3 ]
  ++ lib.optionals withQt5 (
    with qt5;
    [
      qtbase
      qttools
    ]
    ++ lib.optionals withX11 [ qtx11extras ]
  );

  mesonFlags = [
    (mesonEnable "gtk2" withGtk2)
    (mesonEnable "gtk3" withGtk3)
    (mesonEnable "qt5" withQt5)
    (mesonEnable "x11" withX11)
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Lightweight C library for loading and wrapping LV2 plugin UIs";
    homepage = "http://drobilla.net/software/suil";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
