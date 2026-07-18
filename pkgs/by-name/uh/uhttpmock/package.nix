{
  lib,
  stdenv,
  fetchFromGitLab,
  docbook-xsl-nons,
  glib,
  gobject-introspection,
  gtk-doc,
  libsoup_3,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uhttpmock";
  version = "0.11.0";

  src = fetchFromGitLab {
    owner = "pwithnall";
    repo = "uhttpmock";
    rev = finalAttrs.version;
    hash = "sha256-itJhiPpAF5dwLrVF2vuNznABqTwEjVj6W8mbv1aEmE4=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    gtk-doc
    docbook-xsl-nons
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  propagatedBuildInputs = [
    glib
    libsoup_3
  ];

  meta = {
    description = "Project for mocking web service APIs which use HTTP or HTTPS";
    homepage = "https://gitlab.freedesktop.org/pwithnall/uhttpmock/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})
