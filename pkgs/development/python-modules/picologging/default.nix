{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  flaky,
  hypothesis,
  ninja,
  pytestCheckHook,
  python,
  scikit-build,
  setuptools,
}:

buildPythonPackage rec {
  pname = "picologging";
  version = "0.9.4";

  src = fetchFromGitHub {
    # 0.9.4 only release on github
    owner = "microsoft";
    repo = "picologging";
    tag = version;
    hash = "sha256-t75D7aNKAifzeCPwtyKp8LoiXtbbXspRFYnsI0gx+V4=";
  };

  patches = [
    # For python 313
    # https://github.com/microsoft/picologging/pull/212
    ./pr-212.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    cmake
    scikit-build
    ninja
  ];

  dependencies = [
    flaky
    hypothesis
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "picologging" ];

  meta = {
    description = "Optimized logging library for Python";
    homepage = "https://github.com/microsoft/picologging";
    changelog = "https://github.com/microsoft/picologging/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
  };
}
