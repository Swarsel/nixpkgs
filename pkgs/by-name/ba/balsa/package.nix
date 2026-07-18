{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  gmime3,
  gnutls,
  gpgme,
  gtk3,
  gtksourceview4,
  gtkspell3,
  libcanberra-gtk3,
  libesmtp,
  libical,
  libnotify,
  libsecret,
  meson,
  ninja,
  openssl,
  pkg-config,
  sqlite,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "balsa";
  version = "2.6.5";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "balsa";
    tag = finalAttrs.version;
    hash = "sha256-KvgDIFbXmVkTqOibKF+8UhupEDgdhje600aSbmeKZqo=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gmime3
    gnutls
    gpgme
    gtk3
    gtksourceview4
    gtkspell3
    libcanberra-gtk3
    libesmtp
    libical
    libnotify
    libsecret
    openssl
    sqlite
    webkitgtk_4_1
  ];

  configureFlags = [
    "--with-canberra"
    "--with-gtksourceview"
    "--with-libsecret"
    "--with-spell-checker=gtkspell"
    "--with-sqlite"
    "--with-ssl"
    "--with-unique"
    "--without-gnome"
  ];

  mesonFlags = [
    (lib.mesonOption "sysconfdir" "etc")
  ];

  enableParallelBuilding = true;

  meta = {
    description = "E-mail client for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/balsa";
    changelog = "https://gitlab.gnome.org/GNOME/balsa/-/blob/master/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ timon ];
    platforms = lib.platforms.unix;
    mainProgram = "balsa";
  };
})
