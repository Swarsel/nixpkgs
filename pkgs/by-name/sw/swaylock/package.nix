{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  gdk-pixbuf,
  librsvg,
  libxkbcommon,
  meson,
  ninja,
  pam,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wrapGAppsNoGuiHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swaylock";
  version = "1.8.6";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "swaylock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AkH3i9egklFm8z+0M46jFx9VubGWsRGwN1eLkrwkgfs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
    wrapGAppsNoGuiHook
    gdk-pixbuf
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    cairo
    gdk-pixbuf
    pam
    librsvg
  ];

  mesonFlags = [
    "-Dpam=enabled"
    "-Dgdk-pixbuf=enabled"
    "-Dman-pages=enabled"
  ];

  depsBuildBuild = [ pkg-config ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Screen locker for Wayland";

    longDescription = ''
      swaylock is a screen locking utility for Wayland compositors.
      Important note: If you don't use the Sway module (programs.sway.enable)
      you need to set "security.pam.services.swaylock = {};" manually.
    '';

    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.linux;
    mainProgram = "swaylock";
  };
})
