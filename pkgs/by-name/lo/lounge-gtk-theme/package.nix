{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  gnome-shell,
  gtk-engine-murrine,
  gtk3,
  librsvg,
  meson,
  ninja,
  sassc,
}:

stdenv.mkDerivation rec {
  pname = "lounge-gtk-theme";
  version = "1.24";

  src = fetchFromGitHub {
    owner = "monday15";
    repo = "lounge-gtk-theme";
    rev = version;
    sha256 = "0ima0aa5j296xn4y0d1zj6vcdrdpnihqdidj7bncxzgbnli1vazs";
  };

  nativeBuildInputs = [
    meson
    ninja
    sassc
    gtk3
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
  ];

  mesonFlags = [
    "-D gnome_version=${lib.versions.majorMinor gnome-shell.version}"
  ];

  postFixup = ''
    gtk-update-icon-cache "$out"/share/icons/Lounge-aux;
  '';

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = {
    description = "Simple and clean GTK theme with vintage scrollbars, inspired by Absolute, based on Adwaita";
    homepage = "https://github.com/monday15/lounge-gtk-theme";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.unix;
  };
}
