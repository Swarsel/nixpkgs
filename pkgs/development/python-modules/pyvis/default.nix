{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ipython,
  jinja2,
  jsonpickle,
  networkx,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyvis";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "WestHealth";
    repo = "pyvis";
    tag = "v${version}";
    hash = "sha256-eo9Mk2c0hrBarCrzwmkXha3Qt4Bl1qR7Lhl9EkUx96E=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
    numpy
  ];

  dependencies = [
    jinja2
    networkx
    ipython
    jsonpickle
  ];

  disabledTestPaths = [
    # jupyter integration test with selenium and webdriver_manager
    "pyvis/tests/test_html.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyvis" ];

  meta = {
    description = "Python package for creating and visualizing interactive network graphs";
    homepage = "https://github.com/WestHealth/pyvis";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
