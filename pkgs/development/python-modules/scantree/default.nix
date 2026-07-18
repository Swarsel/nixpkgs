{
  lib,
  attrs,
  buildPythonPackage,
  fetchPypi,
  pathspec,
  pytestCheckHook,
  setuptools,
  versioneer,
}:

buildPythonPackage rec {
  pname = "scantree";
  version = "0.0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Fb1cskSDsE2yxwZTYE6Oo1IumAh9t+OKuEgvBTmEwKw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    attrs
    pathspec
  ];

  pyproject = true;

  pythonImportsCheck = [
    "scantree"
  ];

  meta = {
    description = "Flexible recursive directory iterator: scandir meets glob(\"**\", recursive=True)";
    homepage = "https://github.com/andhus/scantree";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wentasah ];
  };
}
