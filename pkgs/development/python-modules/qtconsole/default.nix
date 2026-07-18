{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  ipykernel,
  jupyter-client,
  jupyter-core,
  pygments,
  pyqt6,
  # tests
  pytestCheckHook,
  qtpy,
  # build-system
  setuptools,
  traitlets,
}:

buildPythonPackage (finalAttrs: {
  pname = "qtconsole";
  version = "5.7.2";

  src = fetchFromGitHub {
    owner = "jupyter";
    repo = "qtconsole";
    tag = finalAttrs.version;
    hash = "sha256-GL6CAXijlgc/3nj9KaJJgK+AIq6wHdEf0kpgryJ3KuQ=";
  };

  # : cannot connect to X server
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    ipykernel
    jupyter-core
    jupyter-client
    pygments
    pyqt6
    qtpy
    traitlets
  ];

  pyproject = true;
  pythonImportsCheck = [ "qtconsole" ];

  meta = {
    description = "Jupyter Qt console";
    homepage = "https://qtconsole.readthedocs.io/";
    changelog = "https://qtconsole.readthedocs.io/en/stable/changelog.html#changes-in-jupyter-qt-console";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.unix;
    mainProgram = "jupyter-qtconsole";
  };
})
