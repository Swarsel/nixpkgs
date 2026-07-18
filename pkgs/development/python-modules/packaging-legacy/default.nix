{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pretend,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "packaging-legacy";
  version = "23.0.post0";

  src = fetchFromGitHub {
    owner = "di";
    repo = "packaging_legacy";
    tag = version;
    hash = "sha256-2TnJjxasC8+c+qHY60e6Jyqhf1nQJfj/tmIA/LvUsT8=";
  };

  nativeCheckInputs = [
    pretend
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ packaging ];
  pyproject = true;
  pythonImportsCheck = [ "packaging_legacy" ];

  meta = {
    description = "Module to support for legacy Python Packaging functionality";
    homepage = "https://github.com/di/packaging_legacy";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
