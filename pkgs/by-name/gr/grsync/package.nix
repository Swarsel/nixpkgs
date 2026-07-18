{
  lib,
  stdenv,
  fetchurl,
  dee,
  gtk3,
  intltool,
  libdbusmenu-gtk3,
  libunity,
  pkg-config,
  rsync,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "grsync";
  version = "1.3.1";

  src = fetchurl {
    url = "mirror://sourceforge/grsync/grsync-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-M8wOJdqmLlunCRyuo8g6jcdNxddyHEUB00nyEMSzxtM=";
  };

  nativeBuildInputs = [
    intltool
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    dee
    gtk3
    libdbusmenu-gtk3
    libunity
    rsync
  ];

  meta = {
    description = "Synchronize folders, files and make backups";
    homepage = "http://www.opbyte.it/grsync/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.kuznero ];
    platforms = lib.platforms.linux;
    mainProgram = "grsync";
  };
})
