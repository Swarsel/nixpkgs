{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  gitUpdater,
  gtest,
  nlohmann_json,
  openssl,
  pdal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "entwine";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "connormanning";
    repo = "entwine";
    rev = finalAttrs.version;
    hash = "sha256-K/mR3Js5F6JeS9xvEOhzX4sXGK/Zo+1mHCXDSaBdV2M=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gtest
    nlohmann_json
    openssl
    pdal
    curl
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Point cloud organization for massive datasets";
    homepage = "https://entwine.io/";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.linux;
    mainProgram = "entwine";
    teams = [ lib.teams.geospatial ];
  };
})
