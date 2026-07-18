{
  lib,
  fetchFromGitHub,
  astropy,
  buildPythonPackage,
  dill,
  echo,
  fast-histogram,
  h5py,
  ipython,
  matplotlib,
  mpl-scatter-density,
  numpy,
  openpyxl,
  pandas,
  pyqt-builder,
  pytestCheckHook,
  qt6,
  scipy,
  setuptools,
  setuptools-scm,
  shapely,
  xlrd,
}:

buildPythonPackage rec {
  pname = "glueviz";
  version = "1.24.1";

  src = fetchFromGitHub {
    owner = "glue-viz";
    repo = "glue";
    tag = "v${version}";
    hash = "sha256-21XFH1fIt8vLd0blZJn6ZRmLJaof/E30zHrBVLjXOaA=";
  };

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];
  buildInputs = [ pyqt-builder ];
  # collecting ... qt.qpa.xcb: could not connect to display
  # qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in "" even though it was found.
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    astropy
    dill
    echo
    fast-histogram
    h5py
    ipython
    matplotlib
    mpl-scatter-density
    numpy
    openpyxl
    pandas
    scipy
    setuptools
    shapely
    xlrd
  ];

  dontConfigure = true;
  dontWrapQtApps = true;
  pyproject = true;
  pythonImportsCheck = [ "glue" ];

  meta = {
    description = "Linked Data Visualizations Across Multiple Files";
    homepage = "https://glueviz.org";
    license = lib.licenses.bsd3; # https://github.com/glue-viz/glue/blob/main/LICENSE
    maintainers = with lib.maintainers; [ ifurther ];
  };
}
