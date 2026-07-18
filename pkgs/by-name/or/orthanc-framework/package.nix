{
  lib,
  stdenv,
  gtest,
  icu,
  orthanc,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (orthanc)
    src
    version
    nativeBuildInputs
    strictDeps
    cmakeFlags
    ;

  pname = "orthanc-framework";

  buildInputs = orthanc.buildInputs ++ [
    icu
  ];

  env.NIX_LDFLAGS = toString [
    "-L${lib.getLib zlib}"
    "-lz"
    "-L${lib.getLib gtest}"
    "-lgtest"
  ];

  sourceRoot = "${finalAttrs.src.name}/OrthancFramework/SharedLibrary";

  meta = {
    description = "SDK for building Orthanc plugins and related applications";
    homepage = "https://www.orthanc-server.com/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
