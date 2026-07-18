{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyprobables";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "barrust";
    repo = "pyprobables";
    tag = "v${version}";
    hash = "sha256-wUeNmkDzDBXGtMBplS2Hv6rK+M3eijVpYtHMhjIpsy8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "probables" ];

  meta = {
    description = "Probabilistic data structures";
    homepage = "https://github.com/barrust/pyprobables";
    changelog = "https://github.com/barrust/pyprobables/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
