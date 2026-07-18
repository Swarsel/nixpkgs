{
  lib,
  stdenv,
  fetchurl,
  bash,
  copyDesktopItems,
  makeDesktopItem,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "atool";
  version = "0.39.0";

  src = fetchurl {
    url = "mirror://savannah/atool/atool-${finalAttrs.version}.tar.gz";
    sha256 = "aaf60095884abb872e25f8e919a8a63d0dabaeca46faeba87d12812d6efc703b";
  };

  nativeBuildInputs = [ copyDesktopItems ];
  buildInputs = [ perl ];
  configureScript = "${bash}/bin/bash configure";

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Aunpack";
      exec = "atool -x %f";

      mimeTypes = [
        "application/gzip"
        "application/x-7z-compressed"
        "application/x-bzip2"
        "application/x-compressed-tar"
        "application/x-cpio"
        "application/x-gtar"
        "application/x-lha"
        "application/x-lzop"
        "application/x-tar"
        "application/x-xz-compressed-tar"
        "application/zip"
        "application/x-rar"
      ];

      name = "aunpack";
      noDisplay = true;
      terminal = true;
    })
  ];

  meta = {
    description = "Archive command line helper";
    homepage = "https://www.nongnu.org/atool";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    mainProgram = "atool";
  };
})
