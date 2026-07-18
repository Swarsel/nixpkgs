{
  lib,
  stdenv,
  fetchurl,
  gnome-icon-theme,
  gtk3, # any version
  hicolor-icon-theme,
  iconnamingutils,
  imagemagick,
  intltool,
  librsvg,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tango-icon-theme";
  version = "0.8.90";

  src = fetchurl {
    url = "https://tango.freedesktop.org/releases/tango-icon-theme-${finalAttrs.version}.tar.gz";
    hash = "sha256-bpjYAy1X2BisyQfsR+anGIUf8lGufCmq+4aHQ+tlyI4=";
  };

  patches = [ ./rsvg-convert.patch ];
  # still missing parent icon themes: cristalsvg
  strictDeps = true;

  nativeBuildInputs = [
    intltool
    gtk3
    librsvg
    imagemagick
    iconnamingutils
    gnome-icon-theme
    hicolor-icon-theme
  ];

  propagatedBuildInputs = [
    gnome-icon-theme
    hicolor-icon-theme
  ];

  configureFlags = [ "--enable-png-creation" ];

  postInstall = ''
    gtk-update-icon-cache $out/share/icons/Tango
  '';

  __structuredAttrs = true;

  depsBuildBuild = [
    pkg-config
  ];

  dontDropIconThemeCache = true;

  meta = {
    description = "Basic set of icons";
    homepage = "https://tango.freedesktop.org/Tango_Icon_Library";
    license = lib.licenses.publicDomain;
    platforms = lib.platforms.linux;
  };
})
