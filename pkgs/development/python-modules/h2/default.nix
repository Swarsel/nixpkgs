{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hpack,
  hyperframe,
  hypothesis,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "h2";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "python-hyper";
    repo = "h2";
    tag = "v${version}";
    hash = "sha256-04we2xeh5LtLA4La9WPfXQVczDIz7NpL/6y9TmIELgM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  build-system = [ setuptools ];

  dependencies = [
    hpack
    hyperframe
  ];

  disabledTests = [
    # timing sensitive
    "test_changing_max_frame_size"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "h2.connection"
    "h2.config"
  ];

  meta = {
    description = "HTTP/2 State-Machine based protocol implementation";
    homepage = "https://github.com/python-hyper/h2";
    changelog = "https://github.com/python-hyper/h2/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
