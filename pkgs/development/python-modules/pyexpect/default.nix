{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyexpect";
  version = "1.0.22";

  src = fetchFromGitHub {
    owner = "dwt";
    repo = "pyexpect";
    tag = version;
    hash = "sha256-2c+lIpw1q5vF/+7oaVpu743n+xxzf23wXce8oFA7jKw=";
  };

  nativeCheckInputs = [
    unittestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyexpect" ];

  meta = {
    description = "Minimal but very flexible implementation of the expect pattern";
    homepage = "https://github.com/dwt/pyexpect";
    changelog = "https://github.com/dwt/pyexpect/releases/tag/${version}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ lzcunt ];
  };
}
