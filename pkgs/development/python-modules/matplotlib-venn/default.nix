{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  shapely,
}:

buildPythonPackage rec {
  pname = "matplotlib-venn";
  version = "1.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bysHoD6btaYt4vMvllIWc54XUXb51lTdGeevLCLsNuM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    matplotlib
    numpy
    scipy
    shapely
  ];

  disabledTests = [
    # See https://github.com/konstantint/matplotlib-venn/issues/85
    "matplotlib_venn.layout.venn3.cost_based.LayoutAlgorithm"
  ];

  pyproject = true;

  meta = {
    description = "Functions for plotting area-proportional two- and three-way Venn diagrams in matplotlib";
    homepage = "https://github.com/konstantint/matplotlib-venn";
    changelog = "https://github.com/konstantint/matplotlib-venn/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    broken = stdenv.hostPlatform.isDarwin; # https://github.com/konstantint/matplotlib-venn/issues/87
  };
}
