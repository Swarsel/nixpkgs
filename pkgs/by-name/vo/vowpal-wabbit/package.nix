{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  eigen,
  gtest,
  help2man,
  rapidjson,
  spdlog,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vowpal-wabbit";
  version = "9.11.2";

  src = fetchFromGitHub {
    owner = "VowpalWabbit";
    repo = "vowpal_wabbit";
    tag = finalAttrs.version;
    hash = "sha256-A1Eqj843QidqVlADi6qEKFuw+T0h1FxkRwJ9oRTZgeU=";
    fetchSubmodules = true;
  };

  patches = [
    # https://github.com/VowpalWabbit/vowpal_wabbit/pull/4916
    ./add-missing-includes.patch
  ];

  postPatch = ''
    # Avoid duplicate add RapidJSON
    substituteInPlace ext_libs/ext_libs.cmake \
      --replace-fail "add_library(RapidJSON INTERFACE)" ""
  '';

  nativeBuildInputs = [
    cmake
    help2man
  ];

  buildInputs = [
    boost
    eigen
    rapidjson
    spdlog
    zlib
  ];

  cmakeFlags = [
    "-DUSE_LATEST_STD=ON"
    "-DVW_INSTALL=ON"
    "-DBUILD_JAVA=OFF"
    "-DBUILD_PYTHON=OFF"
    "-DRAPIDJSON_SYS_DEP=ON"
    "-DFMT_SYS_DEP=ON"
    "-DSPDLOG_SYS_DEP=ON"
    "-DVW_BOOST_MATH_SYS_DEP=ON"
    "-DVW_EIGEN_SYS_DEP=ON"
    "-DVW_GTEST_SYS_DEP=ON"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-DCMAKE_CTEST_ARGUMENTS=-E;SpanningTreeTest"
  ];

  doCheck = true;

  checkInputs = [
    gtest
  ];

  meta = {
    description = "Machine learning system focused on online reinforcement learning";

    longDescription = ''
      Machine learning system which pushes the frontier of machine learning with techniques such as online,
      hashing, allreduce, reductions, learning2search, active, and interactive and reinforcement learning
    '';

    homepage = "https://github.com/VowpalWabbit/vowpal_wabbit/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jackgerrits ];
    platforms = lib.platforms.unix;
  };
})
