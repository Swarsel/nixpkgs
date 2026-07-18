{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  gnome-shell,
  gnome-themes-extra,
  gtk-engine-murrine,
  librsvg,
  meson,
  ninja,
  sassc,
}:

stdenv.mkDerivation rec {
  pname = "materia-theme";
  version = "20210322";

  src = fetchFromGitHub {
    owner = "nana-4";
    repo = "materia-theme";
    rev = "v${version}";
    sha256 = "1fsicmcni70jkl4jb3fvh7yv0v9jhb8nwjzdq8vfwn256qyk0xvl";
  };

  nativeBuildInputs = [
    meson
    ninja
    sassc
  ];

  buildInputs = [
    gnome-themes-extra
    gdk-pixbuf
    librsvg
  ];

  mesonFlags = [
    "-Dgnome_shell_version=${lib.versions.majorMinor gnome-shell.version}"
  ];

  postInstall = ''
    rm $out/share/themes/*/COPYING
  '';

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = {
    description = "Material Design theme for GNOME/GTK based desktop environments";
    homepage = "https://github.com/nana-4/materia-theme";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
  };
}
