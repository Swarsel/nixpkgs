{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-jupyter-builder,
  hatchling,
}:

buildPythonPackage rec {
  pname = "jupyterlab-widgets";
  version = "3.0.16";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Qj2gUHHVXPJ6nmAiFtNaOmWj5BzfnF07ZDuBTOOMGeA=";
    pname = "jupyterlab_widgets";
  };

  # jupyterlab is required to build from source but we use the pre-build package
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace '"jupyterlab~=4.0"' ""
  '';

  # has no tests
  doCheck = false;

  build-system = [
    hatchling
    hatch-jupyter-builder
  ];

  pyproject = true;
  pythonImportsCheck = [ "jupyterlab_widgets" ];

  meta = {
    description = "Jupyter Widgets JupyterLab Extension";
    homepage = "https://github.com/jupyter-widgets/ipywidgets";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
