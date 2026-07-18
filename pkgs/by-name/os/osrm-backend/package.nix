{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  bzip2,
  cmake,
  expat,
  libxml2,
  libzip,
  lua,
  luabind,
  nixosTests,
  onetbb,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osrm-backend";
  version = "26.4.0";

  src = fetchFromGitHub {
    owner = "Project-OSRM";
    repo = "osrm-backend";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DV0oy++PrOwbybFEFRWnNxGfYshgsqDaHrHuVoTlIXE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    bzip2
    libxml2
    libzip
    boost
    lua
    luabind
    onetbb
    expat
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    # Needed with GCC 12
    "-Wno-error=uninitialized"
    # Needed with GCC 14
    "-Wno-error=maybe-uninitialized"
  ];

  postInstall = ''
    mkdir -p $out/share/osrm-backend
    cp -r ../profiles $out/share/osrm-backend/profiles
  '';

  passthru.tests = {
    inherit (nixosTests) osrm-backend;
  };

  meta = {
    description = "Open Source Routing Machine computes shortest paths in a graph. It was designed to run well with map data from the Openstreetmap Project";
    homepage = "https://project-osrm.org/";
    changelog = "https://github.com/Project-OSRM/osrm-backend/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ erictapen ];
    platforms = lib.platforms.unix;
  };
})
