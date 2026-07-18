{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  autoreconfHook,
  gettext,
  glib,
  gtk2,
  gtk3,
  intltool,
  libfm,
  libx11,
  nix-update-script,
  pango,
  pkg-config,
  wrapGAppsHook3,
  withGtk3 ? true,
}:

let
  libfm' = libfm.override { inherit withGtk3; };
  gtk = if withGtk3 then gtk3 else gtk2;
  inherit (lib) optional;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pcmanfm";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "lxde";
    repo = "pcmanfm";
    tag = finalAttrs.version;
    hash = "sha256-4kJDCnld//Vbe2KbrLoYZJ/dutagY/GImoOnbpQIdDY=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    intltool
    autoreconfHook
  ];

  buildInputs = [
    glib
    gtk
    libfm'
    libx11
    pango
    adwaita-icon-theme
  ];

  configureFlags = optional withGtk3 "--with-gtk=3";
  env.ACLOCAL = "aclocal -I ${gettext}/share/gettext/m4";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "File manager with GTK interface";
    homepage = "https://blog.lxde.org/category/pcmanfm/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "pcmanfm";
  };
})
