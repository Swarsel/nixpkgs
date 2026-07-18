{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  babel,
  build,
  buildPythonPackage,
  coverage,
  # dependencies
  guidata,
  makefun,
  matplotlib,
  myst-nb,
  myst-parser,
  numpy,
  opencv-python-headless,
  packaging,
  pandas,
  plotpy,
  pre-commit,
  pydata-sphinx-theme,
  pylint,
  pyqt5,
  pytest,
  pytest-xvfb,
  # tests
  pytestCheckHook,
  pywavelets,
  qtpy,
  ruff,
  scikit-image,
  scipy,
  # build-system
  setuptools,
  sphinx,
  sphinx-copybutton,
  sphinx-design,
  sphinx-gallery,
  sphinx-intl,
  typing-extensions,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "sigima";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "DataLab-Platform";
    repo = "Sigima";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WRuTncx6iKQVdKjDaSwg/hVcBM4WxLGq1pcMEMXMVQI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    guidata
    makefun
    numpy
    packaging
    pandas
    pywavelets
    scikit-image
    scipy
    typing-extensions
  ];

  optional-dependencies = {
    dev = [
      babel
      build
      coverage
      pre-commit
      pylint
      ruff
      setuptools
      wheel
    ];

    doc = [
      matplotlib
      myst-nb
      myst-parser
      opencv-python-headless
      plotpy
      pydata-sphinx-theme
      pyqt5
      qtpy
      sphinx
      sphinx-copybutton
      sphinx-design
      sphinx-gallery
      sphinx-intl
    ];

    opencv = [
      opencv-python-headless
    ];

    qt = [
      plotpy
      pyqt5
      qtpy
    ];

    test = [
      pytest
      pytest-xvfb
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "sigima"
  ];

  pythonRelaxDeps = [
    "scipy"
  ];

  meta = {
    description = "Scientific computing engine for 1D signals and 2D images";
    homepage = "https://github.com/DataLab-Platform/Sigima";
    changelog = "https://github.com/DataLab-Platform/Sigima/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
