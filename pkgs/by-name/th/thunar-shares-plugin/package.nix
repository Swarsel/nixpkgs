{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  meson,
  ninja,
  pkg-config,
  thunar,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thunar-shares-plugin";
  version = "0.5.0";

  src = fetchFromGitLab {
    owner = "thunar-plugins";
    repo = "thunar-shares-plugin";
    tag = "thunar-shares-plugin-${finalAttrs.version}";
    hash = "sha256-sWLFagoLy1lbAsPYKm8GWwCH+Aa++cDXbRDwkNh6bKk=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    glib
    gtk3
    thunar
    xfconf
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "thunar-shares-plugin-"; };

  meta = {
    description = "Thunar plugin providing quick folder sharing using Samba without requiring root access";
    homepage = "https://gitlab.xfce.org/thunar-plugins/thunar-shares-plugin";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
