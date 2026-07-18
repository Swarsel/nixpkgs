{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  gtest,
  hydra-core,
  nlohmann_json,
  pybind11,
  pyvirtualdisplay,
  replaceVars,
  setuptools,
  sfml_2,
}:

buildPythonPackage {
  pname = "nocturne";
  version = "0-unstable-2024-06-19";

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "nocturne";
    rev = "6d1e0f329f7acbed01c934842b269333540af6d2";
    hash = "sha256-Ufhvc+IZUrn8i6Fmu6o81LPjY1Jo0vzsso+eLbI1F2s=";
  };

  patches = [
    (replaceVars ./dependencies.patch {
      gtest_src = gtest.src;
    })
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ sfml_2 ];
  # Test suite requires hydra-submitit-launcher which is not packaged as of 2022-01-02
  doCheck = false;

  build-system = [
    setuptools
  ];

  # hydra-core and pyvirtualdisplay are not declared as dependences but they are requirements
  dependencies = [
    hydra-core
    pyvirtualdisplay
  ];

  dontUseCmakeConfigure = true;

  # Simulate the git submodules but with nixpkgs dependencies
  postUnpack = ''
    rm -rf $sourceRoot/third_party/*
    ln -s ${nlohmann_json.src} $sourceRoot/third_party/json
    ln -s ${pybind11.src} $sourceRoot/third_party/pybind11
  '';

  pyproject = true;
  pythonImportsCheck = [ "nocturne" ];

  meta = {
    description = "Data-driven, fast driving simulator for multi-agent coordination under partial observability";
    homepage = "https://github.com/facebookresearch/nocturne";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
  };
}
