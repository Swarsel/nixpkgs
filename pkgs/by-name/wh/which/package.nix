{
  lib,
  stdenv,
  fetchurl,
  directoryListingUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "which";
  version = "2.25";

  src = fetchurl {
    url = "mirror://gnu/which/which-${finalAttrs.version}.tar.gz";
    hash = "sha256-HLg+T3AuYLghGrXsTCr7qxsd7IAglFan0vr3WE7SJeo=";
  };

  outputs = [
    "out"
    "info"
    "man"
  ];

  patches = [
    ./gcc15.patch
  ];

  strictDeps = true;
  enableParallelBuilding = true;

  passthru.updateScript = directoryListingUpdater {
    inherit (finalAttrs) pname version;
    url = "https://ftp.gnu.org/gnu/which/";
  };

  meta = {
    description = "Shows the full path of (shell) commands";
    homepage = "https://www.gnu.org/software/which/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mdaniels5757 ];
    platforms = lib.platforms.all;
    mainProgram = "which";
  };
})
