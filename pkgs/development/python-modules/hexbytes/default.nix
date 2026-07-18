{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  eth-utils,
  hypothesis,
  pydantic,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hexbytes";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "hexbytes";
    tag = "v${version}";
    hash = "sha256-xYXxlyVGdsksxZJtSpz1V3pj4NL7IzX0gaQeCoiHr8g=";
  };

  nativeCheckInputs = [
    eth-utils
    hypothesis
    pytestCheckHook
    pydantic
  ];

  build-system = [ setuptools ];
  disabledTests = [ "test_install_local_wheel" ];
  pyproject = true;
  pythonImportsCheck = [ "hexbytes" ];

  meta = {
    description = "`bytes` subclass that decodes hex, with a readable console output";
    homepage = "https://github.com/ethereum/hexbytes";
    changelog = "https://github.com/ethereum/hexbytes/blob/v${version}/docs/release_notes.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
