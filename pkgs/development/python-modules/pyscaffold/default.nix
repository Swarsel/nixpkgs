{
  lib,
  build,
  buildPythonPackage,
  certifi,
  colorama,
  configupdater,
  fetchPypi,
  flake8,
  importlib-metadata,
  packaging,
  platformdirs,
  pre-commit,
  pyscaffoldext-cookiecutter,
  pyscaffoldext-custom-extension,
  pyscaffoldext-django,
  pyscaffoldext-dsproject,
  pyscaffoldext-markdown,
  pyscaffoldext-travis,
  pytest,
  pytest-cov,
  pytest-randomly,
  pytest-xdist,
  setuptools,
  setuptools-scm,
  sphinx,
  tomlkit,
  tox,
  virtualenv,
  wheel,
}:

buildPythonPackage rec {
  pname = "pyscaffold";
  version = "4.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QIW43pIAufMZ32+Op5lyiPFZqOSyhLBi2bKk1qnBI0w=";
  };

  postPatch = ''
    substituteInPlace setup.cfg --replace "platformdirs>=2,<4" "platformdirs"
  '';

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
    colorama
    configupdater
    importlib-metadata
    packaging
    platformdirs
    setuptools
    setuptools-scm
    tomlkit
  ];

  optional-dependencies = {
    all = [
      pre-commit
      pyscaffoldext-cookiecutter
      pyscaffoldext-custom-extension
      pyscaffoldext-django
      pyscaffoldext-dsproject
      pyscaffoldext-markdown
      pyscaffoldext-travis
      virtualenv
    ];

    ds = [ pyscaffoldext-dsproject ];
    md = [ pyscaffoldext-markdown ];

    testing = [
      build
      certifi
      flake8
      pre-commit
      pytest
      pytest-cov
      pytest-randomly
      pytest-xdist
      setuptools
      setuptools-scm
      sphinx
      tomlkit
      tox
      virtualenv
      wheel
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyscaffold" ];

  meta = {
    description = "Template tool for putting up the scaffold of a Python project";
    homepage = "https://pypi.org/project/PyScaffold/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "putup";
  };
}
