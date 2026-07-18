{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  libgtop,
  lm_sensors,
  pkg-config,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openrgb-plugin-hardwaresync";
  version = "1.0rc2";

  src = fetchFromGitLab {
    owner = "OpenRGBDevelopers";
    repo = "OpenRGBHardwareSyncPlugin";
    tag = "release_candidate_${finalAttrs.version}";
    hash = "sha256-t5NPlmCg0btHpD/hpHSwDRl8LjVoOiT89WoOm3PmhXA=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # Remove prebuilt stuff
    rm -r dependencies/lhwm-cpp-wrapper
  '';

  nativeBuildInputs = [
    pkg-config
    qt6Packages.qmake
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    glib
    libgtop
    lm_sensors
  ];

  meta = {
    description = "Sync your ARGB devices colors with hardware measures (CPU, GPU, fan speed, etc...)";
    homepage = "https://gitlab.com/OpenRGBDevelopers/OpenRGBHardwareSyncPlugin";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.linux;
  };
})
