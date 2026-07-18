{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "immutables";
  version = "0.21";

  src = fetchFromGitHub {
    owner = "MagicStack";
    repo = "immutables";
    tag = "v${version}";
    hash = "sha256-wZuCZEVXzycqA/h27RIe59e2QQALem8mfb3EdjwQr9w=";
  };

  postPatch = ''
    rm tests/conftest.py
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # avoid dependency on mypy
    "tests/test_mypy.py"
  ];

  disabledTests = [
    # Version mismatch
    "testMypyImmu"
  ];

  pyproject = true;
  pythonImportsCheck = [ "immutables" ];

  meta = {
    description = "Immutable mapping type";
    homepage = "https://github.com/MagicStack/immutables";
    changelog = "https://github.com/MagicStack/immutables/releases/tag/v${version}";
    license = with lib.licenses; [ asl20 ];
  };
}
