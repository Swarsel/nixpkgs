{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  numpy,
  oldest-supported-numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "dtw-python";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "DynamicTimeWarping";
    repo = "dtw-python";
    tag = "v${version}";
    hash = "sha256-4OP6Fop04HLHURUagLMW4D93zTv9FwAtZ6xyNFbJILA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # We need to run tests on real built package: https://github.com/NixOS/nixpkgs/issues/255262
  # tests/ are not included to output package, so we have to set path explicitly
  preCheck = ''
    appendToVar enabledTestPaths "$src/tests"
    cd $out
  '';

  build-system = [
    cython
    oldest-supported-numpy
    setuptools
    wheel
  ];

  dependencies = [
    scipy
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "dtw" ];

  meta = {
    description = "Python port of R's Comprehensive Dynamic Time Warp algorithms package";
    homepage = "https://github.com/DynamicTimeWarping/dtw-python";
    changelog = "https://github.com/DynamicTimeWarping/dtw-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "dtw";
  };
}
