{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "labwc-menu-generator";
  version = "0.2.0-unstable-2026-06-02";

  src = fetchFromGitHub {
    owner = "labwc";
    repo = "labwc-menu-generator";
    rev = "3785977b3b1bc8a5c4397762538929c5232c5707";
    hash = "sha256-DHqNGtm14tSDKpSZiYGaCaK9ouZPjSJOhq/9CLCMhQw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  doCheck = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Menu generator for labwc";
    homepage = "https://github.com/labwc/labwc-menu-generator";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "labwc-menu-generator";
  };
})
