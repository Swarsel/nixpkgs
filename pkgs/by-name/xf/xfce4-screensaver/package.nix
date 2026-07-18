{
  lib,
  stdenv,
  fetchFromGitLab,
  dbus-glib,
  docbook-xsl-ns,
  docbook_xml_dtd_412,
  garcon,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libwnck,
  libx11,
  libxfce4ui,
  libxfce4util,
  libxklavier,
  libxrandr,
  libxscrnsaver,
  meson,
  ninja,
  pam,
  pkg-config,
  python3,
  systemd,
  wrapGAppsHook3,
  xfconf,
  xfdesktop,
  xmlto,
}:

let
  # For xfce4-screensaver-configure
  pythonEnv = python3.withPackages (pp: [ pp.pygobject3 ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-screensaver";
  version = "4.20.2";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "xfce4-screensaver";
    tag = "xfce4-screensaver-${finalAttrs.version}";
    hash = "sha256-zNA43ZrREZB5D0fNa+mmvtA9tDPxIMVpQsHzx/r+hzk=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    docbook_xml_dtd_412
    docbook-xsl-ns
    gettext
    glib # glib-compile-resources
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    xmlto
  ];

  buildInputs = [
    dbus-glib
    garcon
    glib
    gtk3
    libx11
    libxscrnsaver
    libxrandr
    libwnck
    libxfce4ui
    libxfce4util
    libxklavier
    pam
    pythonEnv
    systemd
    xfconf
  ];

  preFixup = ''
    # For default wallpaper.
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xfdesktop}/share")
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "xfce4-screensaver-"; };

  meta = {
    description = "Screensaver for Xfce";
    homepage = "https://gitlab.xfce.org/apps/xfce4-screensaver";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ symphorien ];
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-screensaver";
    teams = [ lib.teams.xfce ];
  };
})
