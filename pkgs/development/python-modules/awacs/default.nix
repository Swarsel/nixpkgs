{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "awacs";
  version = "2.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eRmxXir9X08+YEVE+Bxa+OuasPokgcUoc1SJWGeRJ58=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "awacs" ];

  meta = {
    description = "AWS Access Policy Language creation library";
    homepage = "https://github.com/cloudtools/awacs";
    changelog = "https://github.com/cloudtools/awacs/blob/${version}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ jlesquembre ];
  };
}
