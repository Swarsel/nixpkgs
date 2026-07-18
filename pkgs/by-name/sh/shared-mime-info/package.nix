{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  glib,
  libxml2,
  meson,
  ninja,
  pkg-config,
  shared-mime-info,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shared-mime-info";
  version = "2.4";

  src = fetchFromGitLab {
    owner = "xdg";
    repo = "shared-mime-info";
    rev = finalAttrs.version;
    hash = "sha256-5eyMkfSBUOD7p8woIYTgz5C/L8uQMXyr0fhL0l23VMA=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    libxml2
  ]
  ++ lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) shared-mime-info;

  buildInputs = [
    libxml2
    glib
  ];

  mesonFlags = [
    "-Dupdate-mimedb=true"
  ];

  meta = {
    description = "Database of common MIME types";
    homepage = "http://freedesktop.org/wiki/Software/shared-mime-info";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.mimame ];
    platforms = lib.platforms.unix;
    mainProgram = "update-mime-database";
    teams = [ lib.teams.freedesktop ];
  };
})
