{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gitUpdater,
  glib,
  gnutls,
  gtk3,
  libgcrypt,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  xfce4-exo,
  xfce4-panel,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-mailwatch-plugin";
  version = "1.4.0";

  src = fetchurl {
    url = "mirror://xfce/src/panel-plugins/xfce4-mailwatch-plugin/${lib.versions.majorMinor finalAttrs.version}/xfce4-mailwatch-plugin-${finalAttrs.version}.tar.xz";
    hash = "sha256-XCEQJdsQlmY/prjMQSE0ZKbXHyTnYyZJnYV/+B6jhh8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libxfce4ui
    libxfce4util
    xfce4-panel
    xfce4-exo
    glib
    gtk3
    gnutls
    libgcrypt
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "xfce4-mailwatch-plugin-";
    url = "https://gitlab.xfce.org/panel-plugins/xfce4-mailwatch-plugin";
  };

  meta = {
    description = "Mail watcher plugin for Xfce panel";
    homepage = "https://docs.xfce.org/panel-plugins/xfce4-mailwatch-plugin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
