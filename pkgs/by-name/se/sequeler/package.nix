{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  gtksourceview4,
  libgda5,
  libgee,
  libsecret,
  libssh2,
  libxml2,
  meson,
  ninja,
  pantheon,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

let
  sqlGda = libgda5.override {
    mysqlSupport = true;
    postgresSupport = true;
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "sequeler";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "ellie-commons";
    repo = "sequeler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dFmR5SfzT/1UVwcnB3Y3kB1h0DapwN/2/KQAHiMpk/8=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    gettext
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    gtk3
    glib
    pantheon.granite
    libgee
    sqlGda
    gtksourceview4
    libxml2
    libsecret
    libssh2
  ];

  passthru = {
    updateScript = gitUpdater {
      # Upstream frequently tags these to fix flatpak builds, which are mostly irrelevant to us.
      ignoredVersions = "-";
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Friendly SQL Client";

    longDescription = ''
      Sequeler is a native Linux SQL client built in Vala and Gtk. It allows you
      to connect to your local and remote databases, write SQL in a handy text
      editor with language recognition, and visualize SELECT results in a
      Gtk.Grid Widget.
    '';

    homepage = "https://github.com/ellie-commons/sequeler";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.github.ellie_commons.sequeler";
    teams = [ lib.teams.pantheon ];
  };
})
