{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jupyter-contrib-core,
  jupyter-core,
  jupyter-server,
  notebook,
  pytestCheckHook,
  pyyaml,
  selenium,
  tornado,
}:

buildPythonPackage rec {
  pname = "jupyter-nbextensions-configurator";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "jupyter-contrib";
    repo = "jupyter_nbextensions_configurator";
    tag = version;
    hash = "sha256-U4M6pGV/DdE+DOVMVaoBXOhfRERt+yUa+gADgqRRLn4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    selenium
  ];

  dependencies = [
    jupyter-contrib-core
    jupyter-core
    jupyter-server
    notebook
    pyyaml
    tornado
  ];

  # Those tests fails upstream
  disabledTestPaths = [
    "tests/test_application.py"
    "tests/test_jupyterhub.py"
    "tests/test_nbextensions_configurator.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "jupyter_nbextensions_configurator" ];

  meta = {
    description = "Jupyter notebook serverextension providing config interfaces for nbextensions";
    homepage = "https://github.com/jupyter-contrib/jupyter_nbextensions_configurator";
    changelog = "https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "jupyter-nbextensions_configurator";
  };
}
