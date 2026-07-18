{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  withCExtensions ? true,
}:

buildPythonPackage rec {
  pname = "cbor2";
  version = "5.8.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-sZw1/K6WiKwB73W61dsnMAwlN+tO4A7QfgXYRWoNSTE=";
  };

  env = lib.optionalAttrs (!withCExtensions) {
    CBOR2_BUILD_C_EXTENSION = "0";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "cbor2" ];

  passthru = {
    inherit withCExtensions;
  };

  meta = {
    description = "Python CBOR (de)serializer with extensive tag support";
    homepage = "https://github.com/agronholm/cbor2";
    changelog = "https://github.com/agronholm/cbor2/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "cbor2";

  };
}
