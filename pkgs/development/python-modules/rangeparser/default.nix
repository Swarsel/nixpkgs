{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rangeparser";
  version = "0.1.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-gjA7Iytg802Lv7/rLfhGE0yjz4e6FfOXbEoWNPjhCOY=";
    pname = "RangeParser";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "rangeparser" ];

  meta = {
    description = "Parses ranges";
    homepage = "https://pypi.org/project/RangeParser/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
