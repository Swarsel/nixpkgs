{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  future,
  numpy,
  pytest-lazy-fixture,
  pytestCheckHook,
  pythonOlder,
  scikit-build,
  setuptools,
}:

buildPythonPackage rec {
  pname = "parselmouth";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "YannickJadoul";
    repo = "Parselmouth";
    tag = "v${version}";
    hash = "sha256-gogNiKZVQaAzu/VeP4+bg61GtdptZeNkQatcJ/cjXFI=";
    fetchSubmodules = true;
  };

  doCheck = pythonOlder "3.13";

  nativeCheckInputs = [
    future
    pytest-lazy-fixture
    pytestCheckHook
  ];

  build-system = [
    cmake
    scikit-build
    setuptools
  ];

  configurePhase = ''
    # doesn't happen automatically
    export MAKEFLAGS=-j$NIX_BUILD_CORES
  '';

  dependencies = [ numpy ];
  dontUseCmakeConfigure = true;
  pyproject = true;

  pytestFlags = [
    "--run-praat-tests"
    "-v"
  ];

  pythonImportsCheck = [ "parselmouth" ];

  meta = {
    description = "Praat in Python, the Pythonic way";
    homepage = "https://github.com/YannickJadoul/Parselmouth";
    changelog = "https://github.com/YannickJadoul/Parselmouth/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
