{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  wirerope,
}:

buildPythonPackage rec {
  pname = "methodtools";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "youknowone";
    repo = "methodtools";
    rev = version;
    hash = "sha256-Y5VdYVSb3A+32waUUoIDDGW+AhRapN71pebTTlJC0es=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ wirerope ];
  pyproject = true;
  pythonImportsCheck = [ "methodtools" ];

  meta = {
    description = "Expands the functools lru_cache to classes";
    homepage = "https://github.com/youknowone/methodtools";
    changelog = "https://github.com/youknowone/methodtools/releases/tag/${version}";
    license = lib.licenses.bsd2WithViews;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
