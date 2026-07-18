{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  gtksourceview,
  gtkspell3,
  itstool,
  meson,
  ninja,
  pandoc,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "marker";
  version = "2023.05.02";

  src = fetchFromGitHub {
    owner = "fabiocolacio";
    repo = "Marker";
    tag = finalAttrs.version;
    hash = "sha256-HhDhigQ6Aqo8R57Yrf1i69sM0feABB9El5R5OpzOyB0=";
    fetchSubmodules = true;
  };

  patches = [
    # https://github.com/fabiocolacio/Marker/pull/427
    ./fix_incompatible_pointer_in_marker_window_init.patch
  ];

  postPatch = ''
    meson rewrite kwargs set project / version '${finalAttrs.version}'
  '';

  nativeBuildInputs = [
    itstool
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gtksourceview
    gtkspell3
    webkitgtk_4_1
    pandoc
  ];

  meta = {
    description = "Markdown editor for the Linux desktop made with GTK3";
    homepage = "https://fabiocolacio.github.io/Marker/";
    changelog = "https://github.com/fabiocolacio/Marker/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "marker";
  };
})
