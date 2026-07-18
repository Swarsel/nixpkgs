{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  fetchpatch,
  gtk4,
  json-glib,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "notejot";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "lainsce";
    repo = "notejot";
    rev = finalAttrs.version;
    hash = "sha256-p5F0OITgfZyvHwndI5r5BE524+nft7A2XfR3BJZFamU=";
  };

  patches = [
    # Fixes the compilation error with new Vala compiler. Remove in the next version.
    (fetchpatch {
      hash = "sha256-dexPKIpUaAu/p0K2WQpElhPNt86CS+jD0dPL5+CTl4I=";
      url = "https://github.com/musicinmybrain/notejot/commit/c6a7cfcb792de63fb51eb174f9f3d4e02f6a2ce1.patch";
    })
  ];

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    json-glib
    libadwaita
    libgee
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Stupidly-simple notes app";
    homepage = "https://github.com/lainsce/notejot";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "io.github.lainsce.Notejot";
  };
})
