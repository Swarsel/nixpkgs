{
  lib,
  stdenv,
  fetchFromGitLab,
  cairo,
  gettext,
  gtk3,
  libxml2,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  pname = "gdmap";
  version = "1.4.0";

  src = fetchFromGitLab {
    owner = "sjohannes";
    repo = "gdmap";
    tag = "v1.4.0";
    sha256 = "sha256-yqrlxmMxtcJqUe9xgs01d1AAc2gkPBPsQbzQfffZET0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    cairo
    libxml2
    gettext
  ];

  meta = {
    description = "Tool to visualize disk space (GTK 3 port of Original)";
    homepage = "https://gitlab.com/sjohannes/gdmap";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.linux;
    mainProgram = "gdmap";
  };
}
