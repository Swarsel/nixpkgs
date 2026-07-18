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
}:

buildPythonPackage rec {
  pname = "doubleratchet";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-doubleratchet";
    tag = "v${version}";
    hash = "sha256-iw0JIegwEiBpA/9blGKb0Oh1K3j74A3ZomtMRKgJL0E=";
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
    cryptography
    pydantic
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "doubleratchet" ];

  meta = {
    description = "Python implementation of the Double Ratchet algorithm";
    homepage = "https://github.com/Syndace/python-doubleratchet";
    changelog = "https://github.com/Syndace/python-doubleratchet/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ axler1 ];
    teams = with lib.teams; [ ngi ];
  };
}
