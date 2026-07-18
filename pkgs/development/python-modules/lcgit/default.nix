{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lcgit";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "cisagov";
    repo = "lcgit";
    tag = "v${version}";
    hash = "sha256-nCsTA0BKE/0afcqqqEx0mUrLOFbta14TPtNXHD67mas=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lcgit" ];

  meta = {
    description = "Pythonic Linear Congruential Generator iterator";
    homepage = "https://github.com/cisagov/lcgit";
    changelog = "https://github.com/cisagov/lcgit/releases/tag/${src.tag}";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ fab ];
  };
}
