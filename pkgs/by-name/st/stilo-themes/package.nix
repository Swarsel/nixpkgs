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
  pname = "stilo-themes";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "lassekongo83";
    repo = "stilo-themes";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-YKEDXrOAn7pGWb0VcOx7cKHnuX120yPzqtUVnzyLrDQ=";
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
    description = "Minimalistic GTK, gnome shell and Xfce themes";
    homepage = "https://github.com/lassekongo83/stilo-themes";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
  };
})
