{
  lib,
  fetchFromGitHub,
  breezy,
  build,
  buildPythonPackage,
  git,
  pep517,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "check-manifest";
  version = "0.51";

  src = fetchFromGitHub {
    owner = "mgedmin";
    repo = "check-manifest";
    tag = version;
    hash = "sha256-tT6xQZwqJIsyrO9BjWweIeNgYaopziewerVBk0mFVYg=";
  };

  nativeCheckInputs = [
    git
    pytestCheckHook
  ];

  checkInputs = [ breezy ];
  build-system = [ setuptools ];

  dependencies = [
    build
    pep517
    setuptools
  ];

  disabledTests = [
    # Test wants to setup a venv
    "test_build_sdist_pep517_isolated"
  ];

  pyproject = true;
  pythonImportsCheck = [ "check_manifest" ];

  meta = {
    description = "Check MANIFEST.in in a Python source package for completeness";
    homepage = "https://github.com/mgedmin/check-manifest";
    changelog = "https://github.com/mgedmin/check-manifest/blob/${version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lewo ];
    mainProgram = "check-manifest";
  };
}
