{
  lib,
  stdenv,
  fetchFromGitHub,
  bc,
  gdk-pixbuf,
  glib,
  gnome-shell,
  gtk-engine-murrine,
  librsvg,
  libxml2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "equilux-theme";
  version = "20181029";

  src = fetchFromGitHub {
    owner = "ddnexus";
    repo = "equilux-theme";
    tag = "equilux-v${finalAttrs.version}";
    hash = "sha256-zCEo2D6/PH0MBbb8ssg415EWA1iWm1Nu59NWC7v3YlM=";
  };

  nativeBuildInputs = [
    glib
    libxml2
    bc
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
  ];

  installPhase = ''
    patchShebangs install.sh
    sed -i install.sh \
      -e "s|if .*which gnome-shell.*;|if true;|" \
      -e "s|CURRENT_GS_VERSION=.*$|CURRENT_GS_VERSION=${lib.versions.majorMinor gnome-shell.version}|"
    mkdir -p $out/share/themes
    ./install.sh --dest $out/share/themes
    rm $out/share/themes/*/COPYING
  '';

  dontBuild = true;
  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Material Design theme for GNOME/GTK based desktop environments";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.fpletz ];
    platforms = lib.platforms.all;
  };
})
