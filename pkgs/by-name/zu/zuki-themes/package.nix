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
  pname = "zuki-themes";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "lassekongo83";
    repo = "zuki-themes";
    rev = "v${finalAttrs.version}";
    sha256 = "1q026wa8xgyb6f5k7pqpm5zav30dbnm3b8w59as3sh8rhfgpbf80";
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
    description = "Themes for GTK, gnome-shell and Xfce";
    homepage = "https://github.com/lassekongo83/zuki-themes";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
  };
})
