{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  desktop-file-utils,
  evolution-data-server,
  feedbackd,
  glibmm,
  gnome-desktop,
  gspell,
  gst_all_1,
  gtk4,
  gtksourceview5,
  itstool,
  libadwaita,
  libcmatrix,
  libphonenumber,
  libsecret,
  meson,
  modemmanager,
  ninja,
  pidgin,
  pkg-config,
  protobuf,
  sqlite,
  wrapGAppsHook4,
  plugins ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chatty";
  version = "0.8.9";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Chatty";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XLpvgRSvIi3Wk5SaomROp94HDT8JNFfLdRX1PJgQYkI=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    itstool
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    evolution-data-server
    feedbackd
    glibmm
    libsecret
    gnome-desktop
    gspell
    gtk4
    gtksourceview5
    gst_all_1.gstreamer
    libcmatrix
    libadwaita
    libphonenumber
    modemmanager
    pidgin
    protobuf
    sqlite
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PURPLE_PLUGIN_PATH : ${lib.escapeShellArg (pidgin.makePluginPath plugins)}
      ${lib.concatMapStringsSep " " (p: p.wrapArgs or "") plugins}
    )
  '';

  meta = {
    description = "XMPP and SMS messaging via libpurple and ModemManager";
    homepage = "https://gitlab.gnome.org/World/Chatty";
    changelog = "https://gitlab.gnome.org/World/Chatty/-/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.linux;
    mainProgram = "chatty";
  };
})
