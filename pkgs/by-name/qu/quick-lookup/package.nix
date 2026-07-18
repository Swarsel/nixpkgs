{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gjs,
  glib-networking,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "quick-lookup";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "johnfactotum";
    repo = "quick-lookup";
    tag = finalAttrs.version;
    hash = "sha256-KENHYdhB1OHIB1RKyv78QFdsq3fYRqKgBDCFPLxHZ+k=";
  };

  postPatch = ''
    substituteInPlace post_install.py \
      --replace-fail 'gtk-update-icon-cache' 'gtk4-update-icon-cache'
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    gjs
    webkitgtk_6_0
    glib-networking
  ];

  meta = {
    description = "Simple GTK dictionary application powered by Wiktionary";
    homepage = "https://github.com/johnfactotum/quick-lookup";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "quick-lookup";
  };
})
