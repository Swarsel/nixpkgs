{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  perl,
  pkg-config,
  qt6,
  unstableGitUpdater,
  xkeyboard_config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "labwc-tweaks";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "labwc";
    repo = "labwc-tweaks";
    tag = finalAttrs.version;
    hash = "sha256-himbdQ3cu+9NnbO5mYOKh30WIp55lSIkwvHAC89IzC8=";
  };

  postPatch = ''
    substituteInPlace bin/gen-layout-list --replace-fail /usr/share/X11/xkb ${xkeyboard_config}/share/X11/xkb
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    perl
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Configuration gui app for labwc";
    homepage = "https://github.com/labwc/labwc-tweaks";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      romildo
    ];

    platforms = lib.platforms.unix;
    mainProgram = "labwc-tweaks";
  };
})
