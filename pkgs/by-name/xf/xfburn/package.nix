{
  lib,
  stdenv,
  fetchFromGitLab,
  docbook_xsl,
  gitUpdater,
  glib,
  gst_all_1,
  gtk3,
  libburn,
  libgudev,
  libisofs,
  libxfce4ui,
  libxfce4util,
  libxslt,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  xfce4-exo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfburn";
  version = "0.8.0";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "xfburn";
    tag = "xfburn-${finalAttrs.version}";
    hash = "sha256-10MjUxy1Ul6CVLdEWFnjppgsI4fAUWqkT2azJBzp0/Q=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    docbook_xsl
    glib # glib-genmarshal
    libxslt # xsltproc
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    xfce4-exo
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gtk3
    libburn
    libgudev
    libisofs
    libxfce4ui
    libxfce4util
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfburn-"; };

  meta = {
    description = "Disc burner and project creator for Xfce";
    homepage = "https://gitlab.xfce.org/apps/xfburn";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfburn";
    teams = [ lib.teams.xfce ];
  };
})
