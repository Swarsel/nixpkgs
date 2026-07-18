{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-rerunfailures,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "travispy";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "menegazzo";
    repo = "travispy";
    tag = "v${version}";
    hash = "sha256-jYuRaKtoWaWq6QWinXnuBfqanTCMibouwwWHfcmioGo=";
  };

  postPatch = ''
    # Fix deprecated pytest configuration
    substituteInPlace setup.cfg \
      --replace-fail "[pytest]" "[tool:pytest]"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-rerunfailures
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];

  # Skip tests that require network access
  disabledTests = [
    "test_not_authenticated"
  ];

  pyproject = true;
  pythonImportsCheck = [ "travispy" ];

  tests = [
    "travispy/_tests/"
  ];

  meta = {
    description = "Python API for Travis CI";
    homepage = "https://github.com/menegazzo/travispy";
    changelog = "https://github.com/menegazzo/travispy/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
