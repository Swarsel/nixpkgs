{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mendingwall";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "lawmurray";
    repo = "mendingwall";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bt2DvbtwUaad5j2XpySA4KBfI4953tc1bHRuUUkS84M=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    blueprint-compiler
    gettext
    appstream
    desktop-file-utils
    pkg-config
    ninja
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  __structuredAttrs = true;

  meta = with lib; {
    description = "Fix theme and menu inconsistencies when using multiple desktop environments";
    homepage = "https://mendingwall.indii.org/";
    changelog = "https://github.com/lawmurray/mendingwall/releases/tag/v${finalAttrs.version}";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.jromer ];
    platforms = platforms.linux;
    mainProgram = "mendingwall";
  };
})
