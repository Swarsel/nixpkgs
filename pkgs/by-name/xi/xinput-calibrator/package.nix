{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  libx11,
  libxi,
  libxrandr,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xinput-calibrator";
  version = "0.8.0";

  src = fetchFromGitLab {
    owner = "xorg/app";
    repo = "xinput-calibrator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BxLBLv6g3hfj2ydIliZitGK/oYepvz1LYknvSWnNG58=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    desktop-file-utils
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    libx11
    libxi
    libxrandr
  ];

  meta = {
    description = "Generic touchscreen calibration program for X.Org";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xinput-calibrator";

    license = with lib.licenses; [
      cc-by-sa-30 # icon
      mit
    ];

    maintainers = [ lib.maintainers.flosse ];
    platforms = lib.platforms.linux;
    mainProgram = "xinput_calibrator";
  };
})
