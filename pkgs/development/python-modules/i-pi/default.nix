{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  distutils,
  gfortran,
  makeWrapper,
  mock,
  numpy,
  pytest-mock,
  pytestCheckHook,
  pythonAtLeast,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "i-pi";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "i-pi";
    repo = "i-pi";
    tag = "v${version}";
    hash = "sha256-PGWgeLmYsVftPhjGTMvAzmKMpZo18ssgXYqZ+l48tfs=";
  };

  nativeBuildInputs = [
    gfortran
    makeWrapper
  ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
    pytest-mock
  ]
  ++ lib.optional (pythonAtLeast "3.12") distutils;

  postFixup = ''
    wrapProgram $out/bin/i-pi \
      --set IPI_ROOT $out
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    scipy
  ];

  disabledTests = [
    "test_driver_base"
    "test_driver_forcebuild"
  ];

  enabledTestPaths = [ "ipi_tests/unit_tests" ];
  pyproject = true;

  meta = {
    description = "Universal force engine for ab initio and force field driven (path integral) molecular dynamics";
    homepage = "https://ipi-code.org/";

    license = with lib.licenses; [
      gpl3Only
      mit
    ];

    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
  };
}
