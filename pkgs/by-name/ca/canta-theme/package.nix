{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  gdk-pixbuf,
  gnome-icon-theme,
  gtk-engine-murrine,
  gtk3,
  hicolor-icon-theme,
  librsvg,
  numix-icon-theme-circle,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "canta-theme";
  version = "2021-09-08";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "canta-theme";
    tag = finalAttrs.version;
    sha256 = "05h42nrggb6znzjcbh4lqqfcm41h4r85n3vwimp3l4lq5p90igr2";
  };

  nativeBuildInputs = [
    gtk3
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    gnome-icon-theme
    numix-icon-theme-circle
    hicolor-icon-theme
  ];

  installPhase = ''
    patchShebangs .
    mkdir -p $out/share/themes
    name= ./install.sh --dest $out/share/themes
    rm $out/share/themes/*/{AUTHORS,COPYING}
    install -D -t $out/share/backgrounds wallpaper/canta-wallpaper.svg
    mkdir -p $out/share/icons
    cp -a icons/Canta $out/share/icons
    gtk-update-icon-cache $out/share/icons/Canta
  '';

  dontDropIconThemeCache = true;
  dontWrapQtApps = true;

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  meta = {
    description = "Flat Design theme for GTK based desktop environments";
    homepage = "https://github.com/vinceliuice/Canta-theme";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux; # numix-icon-theme-circle unavailable in darwin
  };
})
