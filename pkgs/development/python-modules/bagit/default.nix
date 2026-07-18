{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gettext,
  mock,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "bagit";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "LibraryOfCongress";
    repo = "bagit-python";
    tag = "v${version}";
    hash = "sha256-gHilCG07BXL28vBOaqvKhEQw+9l/AkzZRQxucBTEDos=";
  };

  nativeBuildInputs = [
    gettext
  ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "bagit" ];

  meta = {
    description = "Python library and command line utility for working with BagIt style packages";
    homepage = "https://libraryofcongress.github.io/bagit-python/";
    license = with lib.licenses; [ publicDomain ];
    maintainers = with lib.maintainers; [ veprbl ];
    mainProgram = "bagit.py";
  };
}
