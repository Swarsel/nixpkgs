{
  lib,
  buildPythonPackage,
  colored,
  fetchPypi,
  numpy,
  pandas,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ansitable";
  version = "0.11.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XUjXVs9/ETlbbtvYz8YJqCsP1BFajqQKQfSM+Rvm4O0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    numpy
    pandas
  ];

  build-system = [ setuptools ];
  dependencies = [ colored ];
  pyproject = true;
  pythonImportsCheck = [ "ansitable" ];

  meta = {
    description = "Quick and easy display of tabular data and matrices with optional ANSI color and borders";
    homepage = "https://pypi.org/project/ansitable/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      djacu
      a-camarillo
    ];
  };
}
