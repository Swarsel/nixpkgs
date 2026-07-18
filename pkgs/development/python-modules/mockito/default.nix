{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  numpy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mockito";
  version = "1.5.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SYJuOQHcgm0CBOk7Ftzhxh3enTqU6tycIJqw4TAoM5M=";
  };

  nativeBuildInputs = [ hatchling ];

  nativeCheckInputs = [
    numpy
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "mockito" ];

  meta = {
    description = "Spying framework";
    homepage = "https://github.com/kaste/mockito-python";
    changelog = "https://github.com/kaste/mockito-python/blob/${version}/CHANGES.txt";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
