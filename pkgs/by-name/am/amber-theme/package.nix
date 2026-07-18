{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  gtk-engine-murrine,
  gtk_engines,
  librsvg,
  meson,
  ninja,
  sassc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amber-theme";
  version = "3.38-1";

  src = fetchFromGitHub {
    owner = "lassekongo83";
    repo = "amber-theme";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-OrdBeAD+gdIu6u8ESE9PtqYadSuJ8nx1Z8fB4D9y4W4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    sassc
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
    gtk_engines
  ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = {
    description = "GTK, gnome-shell and Xfce theme based on Ubuntu Ambiance";
    homepage = "https://github.com/lassekongo83/amber-theme";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
  };
})
