{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cacert,
  callPackage,
  cmake,
  curl,
  gtest,
  libtiff,
  nlohmann_json,
  pkg-config,
  python3,
  sqlite,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "proj";
  version = "9.8.1";

  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "PROJ";
    tag = finalAttrs.version;
    hash = "sha256-sOAxWihgU1TAMWcju5LN4cPenHHoGgd4oYJ4HA3F/Ks=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # https://github.com/OSGeo/PROJ/pull/3252
    ./only-add-curl-for-static-builds.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    sqlite
    libtiff
    curl
    nlohmann_json
  ];

  cmakeFlags = [
    "-DUSE_EXTERNAL_GTEST=ON"
    "-DRUN_NETWORK_DEPENDENT_TESTS=OFF"
    "-DNLOHMANN_JSON_ORIGIN=external"
    "-DEXE_SQLITE3=${lib.getExe buildPackages.sqlite}"
  ];

  doCheck = true;

  nativeCheckInputs = [
    cacert
    sqlite
    writableTmpDirAsHomeHook
  ];

  checkInputs = [
    gtest
  ];

  preCheck =
    let
      libPathEnvVar = if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
    in
    ''
      export TMP=$TMPDIR
      export ${libPathEnvVar}=$PWD/lib
    '';

  __structuredAttrs = true;

  passthru.tests = {
    proj = callPackage ./tests.nix { proj = finalAttrs.finalPackage; };
    python = python3.pkgs.pyproj;
  };

  meta = {
    description = "Cartographic Projections Library";
    homepage = "https://proj.org/";
    changelog = "https://github.com/OSGeo/PROJ/blob/${finalAttrs.src.tag}/NEWS.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.geospatial ];
  };
})
