{
  lib,
  altair,
  buildPythonPackage,
  fetchPypi,
  ipytablewidgets,
  ipywidgets,
  jupyter,
  jupyter-core,
  jupyterlab,
  pandas,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "vega";
  version = "4.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8lrmhCvwczqBpiQRCkPjmiYsJPHEFnZab/Azkh+i7ls=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    ipytablewidgets
    jupyter
    jupyter-core
    pandas
  ];

  nativeCheckInputs = [
    altair
    pytestCheckHook
  ];

  disabledTestPaths = [
    # these tests are broken with jupyter-notebook >= 7
    "vega/tests/test_entrypoint.py"
  ];

  optional-dependencies = {
    jupyterlab = [ jupyterlab ];
    widget = [ ipywidgets ];
  };

  pyproject = true;
  pythonImportsCheck = [ "vega" ];
  pythonRelaxDeps = [ "pandas" ];

  meta = {
    description = "IPython/Jupyter widget for Vega and Vega-Lite";

    longDescription = ''
      To use this you have to enter a nix-shell with vega. Then run:

      jupyter nbextension install --user --py vega
      jupyter nbextension enable --user vega
    '';

    homepage = "https://github.com/vega/ipyvega";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ teh ];
  };
}
