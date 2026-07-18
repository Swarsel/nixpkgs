{
  lib,
  fetchFromGitHub,
  astropy,
  astropy-helpers,
  beautifulsoup4,
  boto3,
  buildPythonPackage,
  html5lib,
  keyring,
  matplotlib,
  pillow,
  pytest,
  pytest-astropy,
  pytest-dependency,
  pytest-rerunfailures,
  pytest-timeout,
  pytestCheckHook,
  pyvo,
  requests,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "astroquery";
  version = "0.4.11";

  src = fetchFromGitHub {
    owner = "astropy";
    repo = "astroquery";
    tag = "v${version}";
    hash = "sha256-BcdRBPnJfuW17p31xUhjBmP7Lv98CnmOTCO4aU0xpMM=";
  };

  # Disable automatic update of the astropy-helper module
  postPatch = ''
    substituteInPlace setup.cfg --replace "auto_use = True" "auto_use = False"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  checkInputs = [
    boto3
    matplotlib
    pillow
    pytest
    pytest-astropy
    pytest-dependency
    pytest-rerunfailures
    pytest-timeout
    writableTmpDirAsHomeHook
  ];

  # Tests must be run in the build directory.
  preCheck = ''
    cd build/lib
  '';

  build-system = [
    astropy-helpers
    setuptools
  ];

  dependencies = [
    astropy
    requests
    keyring
    beautifulsoup4
    html5lib
    pyvo
  ];

  pyproject = true;
  pythonImportsCheck = [ "astroquery" ];

  meta = {
    description = "Functions and classes to access online data resources";
    homepage = "https://astroquery.readthedocs.io/";
    changelog = "https://github.com/astropy/astroquery/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.smaret ];
  };
}
