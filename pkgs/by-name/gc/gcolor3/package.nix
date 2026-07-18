{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gtk3,
  libportal-gtk3,
  libxml2,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gcolor3";
  version = "2.4.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "gcolor3";
    rev = "v${finalAttrs.version}";
    sha256 = "rHIAjk2m3Lkz11obgNZaapa1Zr2GDH7XzgzuAJmq+MU=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    chmod +x meson_install.sh # patchShebangs requires executable file
    patchShebangs meson_install.sh

    # https://gitlab.gnome.org/World/gcolor3/merge_requests/151
    substituteInPlace meson.build --replace "dependency(${"\n"}  'libportal'" "dependency(${"\n"}  'libportal-gtk3'"
    substituteInPlace src/gcolor3-color-selection.c --replace "libportal/portal-gtk3.h" "libportal-gtk3/portal-gtk3.h"
  '';

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
    libxml2 # xml-stripblanks preprocessing of GResource
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libportal-gtk3
  ];

  meta = {
    description = "Simple color chooser written in GTK3";
    homepage = "https://gitlab.gnome.org/World/gcolor3";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "gcolor3";
  };
})
