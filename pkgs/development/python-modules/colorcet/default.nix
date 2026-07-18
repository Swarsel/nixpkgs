{
  lib,
  buildPythonPackage,
  fetchPypi,
  param,
  pyct,
  pytest-mpl,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "colorcet";
  version = "3.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SNmmfm5Z3FwKllqhtG/l1Zzclcw2qVlJ8pMT+VCsWfc=";
  };

  nativeCheckInputs = [
    pytest-mpl
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    mkdir -p $HOME/.config/matplotlib
    echo "backend: ps" > $HOME/.config/matplotlib/matplotlibrc
    ln -s $HOME/.config/matplotlib $HOME/.matplotlib
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    param
    pyct
  ];

  disabledTests = [ "matplotlib_default_colormap_plot" ];
  pyproject = true;
  pythonImportsCheck = [ "colorcet" ];

  meta = {
    description = "Collection of perceptually uniform colormaps";
    homepage = "https://colorcet.pyviz.org";
    license = lib.licenses.cc-by-40;
    maintainers = [ ];
    mainProgram = "colorcet";
  };
}
