{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  desktop-file-utils,
  evolution-data-server-gtk4,
  gst_all_1,
  libadwaita,
  libportal-gtk4,
  libpsl,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation {
  pname = "stamp";
  version = "0-unstable-2026-07-13";

  src = fetchFromGitLab {
    owner = "jbrummer";
    repo = "stamp";
    rev = "9bce220c9e094c4d616009ebc87499a68ffc14aa";
    hash = "sha256-mplowqsBTT9ibLxD8pbaIeLSd1pindgXLSPKBjseul8=";
    domain = "gitlab.gnome.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    evolution-data-server-gtk4
    gst_all_1.gstreamer
    libadwaita
    libportal-gtk4
    libpsl
    webkitgtk_6_0
  ];

  __structuredAttrs = true;
  dontUseCmakeConfigure = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=main" ];
  };

  meta = {
    description = "Modern GTK4 email client for the GNOME ecosystem";
    homepage = "https://gitlab.gnome.org/jbrummer/stamp";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.linux;
    mainProgram = "stamp";
  };
}
