{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-httpbin,
  pytestCheckHook,
  pyyaml,
  setuptools,
  six,
  urllib3,
  wrapt,
  yarl,
}:

buildPythonPackage rec {
  pname = "vcrpy";
  version = "8.2.1";

  src = fetchFromGitHub {
    owner = "kevin1024";
    repo = "vcrpy";
    tag = "v${version}";
    hash = "sha256-PlpbBzAj9a4bAfORGozAAsbrzngJt2Pnnp3bI96wYfI=";
  };

  nativeCheckInputs = [
    pytest-httpbin
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyyaml
    six
    urllib3
    wrapt
    yarl
  ];

  disabledTestPaths = [ "tests/integration" ];

  disabledTests = [
    "TestVCRConnection"
    # https://github.com/kevin1024/vcrpy/issues/645
    "test_get_vcr_with_matcher"
    "test_testcase_playback"
  ];

  pyproject = true;
  pythonImportsCheck = [ "vcr" ];

  meta = {
    description = "Automatically mock your HTTP interactions to simplify and speed up testing";
    homepage = "https://github.com/kevin1024/vcrpy";
    changelog = "https://github.com/kevin1024/vcrpy/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
