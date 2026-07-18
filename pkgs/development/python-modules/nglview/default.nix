{
  lib,
  ase,
  buildPythonPackage,
  fetchPypi,
  ipykernel,
  ipywidgets,
  jupyter-core,
  jupyter-packaging,
  mock,
  notebook,
  notebook-shim,
  numpy,
  pillow,
  pytestCheckHook,
  pythonRelaxDepsHook,
  setuptools-scm,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage rec {
  pname = "nglview";
  version = "4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-LAz/LFseKgpy4zkwh85ErgMIUkxapflTV4EtPtvCboM=";
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
    pillow
    ase
  ];

  build-system = [
    jupyter-packaging
    jupyter-core
    notebook-shim
    setuptools-scm
    writableTmpDirAsHomeHook
  ];

  dependencies = [
    notebook
    ipywidgets
    ipykernel
    numpy
  ];

  disabledTests = [
    # requires parmed
    "test_show_schrodinger"
    # requires older moviepy
    "test_movie_maker"
  ];

  pyproject = true;
  pythonImportsCheck = [ "nglview" ];
  # NGLview demands numpy < 2.3, but nixpkgs ships >= 2.4
  pythonRelaxDeps = [ "numpy" ];

  meta = {
    description = "IPython/Jupyter widget to interactively view molecular structures and trajectories";
    homepage = "https://github.com/nglviewer/nglview";
    changelog = "https://github.com/nglviewer/nglview/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ guelakais ];
  };
}
