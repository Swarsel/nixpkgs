{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  libxml2,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
  wrapGAppsHook3,
  xkeyboard_config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "labwc-tweaks-gtk";
  version = "0-unstable-2026-05-31";

  src = fetchFromGitHub {
    owner = "labwc";
    repo = "labwc-tweaks-gtk";
    rev = "5cb8680865c72d1b9c9dfd5b41fb5f2bb58e22d9";
    hash = "sha256-Sd3crtELVFkvPMPLL9hXifwgeOhlj1Hlgm3V6EPfT3I=";
  };

  postPatch = ''
    substituteInPlace stack-lang.c --replace /usr/share/X11/xkb ${xkeyboard_config}/share/X11/xkb
    substituteInPlace theme.c --replace /usr/share /run/current-system/sw/share
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libxml2
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Configuration gui app for labwc; gtk fork";
    homepage = "https://github.com/labwc/labwc-tweaks-gtk";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "labwc-tweaks-gtk";
  };
})
