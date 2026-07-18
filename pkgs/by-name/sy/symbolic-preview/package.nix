{
  lib,
  stdenv,
  fetchurl,
  cargo,
  desktop-file-utils,
  glib,
  gtk4,
  libadwaita,
  libxml2,
  meson,
  ninja,
  pkg-config,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "symbolic-preview";
  version = "0.0.9";

  src = fetchurl {
    url = "https://gitlab.gnome.org/World/design/symbolic-preview/uploads/e2fed158fc0d267f2051302bcf14848b/symbolic-preview-${finalAttrs.version}.tar.xz";
    hash = "sha256-kx+70LCQzzWAw2Xd3fKGq941540IM3Y1+r4Em4MNWbw=";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    libxml2
  ];

  meta = {
    description = "Symbolics made easy";
    homepage = "https://gitlab.gnome.org/World/design/symbolic-preview";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = lib.platforms.unix;
    mainProgram = "symbolic-preview";
    # never built on aarch64-darwin, x86_64-darwin since first introduction in nixpkgs
    broken = stdenv.hostPlatform.isDarwin;
  };
})
