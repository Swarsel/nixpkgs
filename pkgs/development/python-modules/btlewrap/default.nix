{
  lib,
  fetchFromGitHub,
  bluepy,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "btlewrap";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "ChristianKuehnel";
    repo = "btlewrap";
    tag = "v${version}";
    hash = "sha256-cjPj+Uw/L9kq/BbxlnOCJtaBcnf9VOJKN2NJ3cmKe6U=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # Require optional dependencies or hardware
    "test/unit_tests/test_bluepy.py"
    "test/unit_tests/test_pygatt.py"
    "test/integration_tests/"
    "test/unit_tests/test_available_backends.py"
  ];

  optional-dependencies = {
    bluepy = [ bluepy ];
  };

  pyproject = true;
  pythonImportsCheck = [ "btlewrap" ];

  meta = {
    description = "Wrapper around different bluetooth low energy backends";
    homepage = "https://github.com/ChristianKuehnel/btlewrap";
    changelog = "https://github.com/ChristianKuehnel/btlewrap/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
