{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  discount,
  gettext,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  sqlite,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bookup";
  version = "1.1.5";

  src = fetchFromGitLab {
    owner = "ilhooq";
    repo = "bookup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s2j9AQMDJaKtYyXtHDscujPv2KIvO0pnX/OnXma93Ro=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext # msgfmt
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    gtksourceview5
    webkitgtk_6_0
    discount
    sqlite
  ];

  meta = {
    description = "Markdown note-taking application for Gnome";
    homepage = "https://gitlab.gnome.org/ilhooq/bookup";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
    mainProgram = "bookup";
  };
})
