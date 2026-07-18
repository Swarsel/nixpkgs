{
  lib,
  stdenv,
  fetchurl,
  gdk-pixbuf,
  gettext,
  gitUpdater,
  gtk-engine-murrine,
  gtk2,
  gtk3,
  gtk_engines,
  librsvg,
  mate-icon-theme,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-themes";
  version = "3.22.26";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/themes/${lib.versions.majorMinor finalAttrs.version}/mate-themes-${finalAttrs.version}.tar.xz";
    sha256 = "Ik6J02TrO3Pxz3VtBUlKmEIak8v1Q0miyF/GB+t1Xtc=";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    gtk3
  ];

  buildInputs = [
    mate-icon-theme
    gtk2
    gtk_engines
    gdk-pixbuf
    librsvg
  ];

  postInstall = ''
    gtk-update-icon-cache "$out"/share/icons/ContrastHigh
  '';

  dontDropIconThemeCache = true;
  enableParallelBuilding = true;

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-themes";
  };

  meta = {
    description = "Set of themes from MATE";
    homepage = "https://mate-desktop.org";

    license = with lib.licenses; [
      lgpl21Plus
      lgpl3Only
      gpl3Plus
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})
