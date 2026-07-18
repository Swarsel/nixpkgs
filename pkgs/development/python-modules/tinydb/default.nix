{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "tinydb";
  version = "4.8.2";

  src = fetchFromGitHub {
    owner = "msiemens";
    repo = "tinydb";
    tag = "v${version}";
    hash = "sha256-N/45XB7ZuZiq25v6DQx4K9NRVnBbUHPeiKKbxQ9YB3E=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pyyaml
  ];

  build-system = [
    poetry-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "tinydb" ];

  meta = {
    description = "Lightweight document oriented database written in Python";
    homepage = "https://tinydb.readthedocs.org/";
    changelog = "https://tinydb.readthedocs.io/en/latest/changelog.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marcus7070 ];
  };
}
