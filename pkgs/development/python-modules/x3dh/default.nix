{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  typing-extensions,
  xeddsa,
}:
buildPythonPackage rec {
  pname = "x3dh";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-x3dh";
    tag = "v${version}";
    hash = "sha256-F2uUooi9N4Ib9cyDul4LXVtG99UYxhEGpZU427P1DFQ=";
  };

  strictDeps = true;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    xeddsa
    cryptography
    pydantic
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "x3dh" ];

  meta = {
    description = "Python Implementation of the Extended Triple Diffie-Hellman key Agreement Protocol";
    homepage = "https://github.com/Syndace/python-x3dh";
    changelog = "https://github.com/Syndace/python-x3dh/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    teams = with lib.teams; [ ngi ];
  };
}
