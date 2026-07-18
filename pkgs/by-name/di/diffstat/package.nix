{
  lib,
  stdenv,
  fetchurl,
  directoryListingUpdater,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "diffstat";
  version = "1.69";

  src = fetchurl {
    hash = "sha256-uwJGQHL3ad2YMv2ZlSZzTJDrTWb7VtU1FUCnUMiKd/Y=";

    urls = [
      "https://invisible-island.net/archives/diffstat/diffstat-${finalAttrs.version}.tgz"
      "https://invisible-mirror.net/archives/diffstat/diffstat-${finalAttrs.version}.tgz"
    ];
  };

  buildInputs = [ zstd ];

  passthru.updateScript = directoryListingUpdater {
    url = "https://invisible-island.net/archives/diffstat/";
  };

  meta = {
    description = "Read output of diff and display a histogram of the changes";

    longDescription = ''
      diffstat reads the output of diff and displays a histogram of the
      insertions, deletions, and modifications per-file. It is useful for
      reviewing large, complex patch files.
    '';

    homepage = "https://invisible-island.net/diffstat/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.unix;
    mainProgram = "diffstat";
  };
})
