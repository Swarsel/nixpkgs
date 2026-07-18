{
  lib,
  stdenv,
  eigen,
  frugally-deep,
  functionalplus,
  nlohmann_json,
  src,
  version,
}:

stdenv.mkDerivation {
  inherit version src;
  pname = "miopen-frugally-deep-model-test";

  buildPhase = ''
    runHook preBuild

    $CXX -std=c++20 \
        -I${lib.getDev eigen}/include/eigen3 \
        -I${lib.getDev functionalplus}/include \
        -I${lib.getDev frugally-deep}/include \
        -I${lib.getDev nlohmann_json}/include \
        ${./test-frugally-deep-model-loading.cpp} \
        -o test_models

    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    echo "Running model loading tests..."
    SRC_DIR="${src}" ./test_models
    mkdir -p $out

    runHook postCheck
  '';

  dontConfigure = true;
  dontInstall = true;

  meta = {
    description = "Test that frugally-deep can load MIOpen model files";
    platforms = lib.platforms.linux;
    teams = with lib.teams; [ rocm ];
  };
}
