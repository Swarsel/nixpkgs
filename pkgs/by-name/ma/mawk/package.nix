{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  directoryListingUpdater,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mawk";
  version = "1.3.4-20240819";

  src = fetchurl {
    hash = "sha256-bh/ejuetilwVOCMWhj/WtMbSP6t4HdWrAXf/o+6arlw=";

    urls = [
      "https://invisible-mirror.net/archives/mawk/mawk-${finalAttrs.version}.tgz"
      "https://invisible-island.net/archives/mawk/mawk-${finalAttrs.version}.tgz"
    ];
  };

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  passthru = {
    tests.version = testers.testVersion {
      command = "mawk -W version";
      package = finalAttrs.finalPackage;
    };

    updateScript = directoryListingUpdater {
      inherit (finalAttrs) pname version;
      url = "https://invisible-island.net/archives/mawk/";
    };
  };

  meta = {
    description = "Interpreter for the AWK Programming Language";
    homepage = "https://invisible-island.net/mawk/mawk.html";
    changelog = "https://invisible-island.net/mawk/CHANGES";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.unix;
    mainProgram = "mawk";
  };
})
