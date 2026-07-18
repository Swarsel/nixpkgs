{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  babel,
  build,
  buildPythonPackage,
  coverage,
  # dependencies
  fastapi,
  guidata,
  httpx,
  myst-parser,
  numpy,
  opencv-python-headless,
  packaging,
  pandas,
  plotpy,
  pre-commit,
  psutil,
  pydantic,
  pydata-sphinx-theme,
  pyinstaller,
  pylint,
  pyqt5,
  pytest,
  pytest-xvfb,
  # tests
  pytestCheckHook,
  pywavelets,
  # build-time
  qt5,
  ruff,
  scikit-image,
  scipy,
  # build-system
  setuptools,
  sigima,
  sphinx,
  sphinx-copybutton,
  sphinx-design,
  sphinx-intl,
  sphinx-sitemap,
  sphinxcontrib-svg2pdfconverter,
  uvicorn,
}:

buildPythonPackage (finalAttrs: {
  pname = "datalab-platform";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "DataLab-Platform";
    repo = "DataLab";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rJDA5qYv2LYMyrckxNy63Gqn8HYU62qG0OAioztKGtA=";
  };

  # NOTE: DataLab is compatible with qt6, but it's apparently not perfect as
  # the executable segfaults on startup. For now, let's use qt5 which works and
  # migrate in the future.
  nativeBuildInputs = [
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.test;

  preFixup = ''
    # Python scripts need to be manually wrapped
    for exe in "$out/bin"/datalab*; do
      wrapQtApp "$exe"
    done
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    fastapi
    guidata
    numpy
    packaging
    pandas
    plotpy
    psutil
    pydantic
    pywavelets
    scikit-image
    scipy
    sigima
    uvicorn
  ]
  ++ finalAttrs.passthru.optional-dependencies.qt
  # required for `bin/datalab-{demo,tests}`
  ++ finalAttrs.passthru.optional-dependencies.test;

  dontWrapQtApps = true;

  optional-dependencies = {
    dev = [
      babel
      build
      coverage
      pre-commit
      pylint
      ruff
    ];

    doc = [
      myst-parser
      pydata-sphinx-theme
      sphinx
      sphinx-copybutton
      sphinx-design
      sphinx-intl
      sphinx-sitemap
      sphinxcontrib-svg2pdfconverter
    ];

    exe = [
      opencv-python-headless
      pyinstaller
      pyqt5
    ];

    opencv = [
      opencv-python-headless
    ];

    qt = [
      pyqt5
    ];

    test = [
      httpx
      pytest
      pytest-xvfb
    ];
  };

  pyproject = true;

  pytestFlags = [
    "--collect-only"
  ];

  pythonImportsCheck = [
    "datalab"
  ];

  pythonRelaxDeps = [
    "guidata"
    "plotpy"
    "scipy"
  ];

  meta = {
    description = "Open-source Platform for Scientific and Technical Data Processing and Visualization";
    homepage = "https://github.com/DataLab-Platform/DataLab";
    changelog = "https://github.com/DataLab-Platform/DataLab/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "datalab";
    teams = with lib.teams; [ ngi ];
  };
})
