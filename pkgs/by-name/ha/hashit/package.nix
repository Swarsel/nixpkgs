{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gtk3,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pantheon,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hashit";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "artemanufrij";
    repo = "hashit";
    rev = finalAttrs.version;
    sha256 = "1s8fbzg1z2ypn55xg1pfm5xh15waq55fkp49j8rsqiq8flvg6ybf";
  };

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    vala
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libgee
    pantheon.granite
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple app for checking usual checksums - Designed for elementary OS";
    homepage = "https://github.com/artemanufrij/hashit";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "com.github.artemanufrij.hashit";
    teams = [ lib.teams.pantheon ];
  };
})
