{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  regex,
  requests,
}:

buildPythonPackage rec {
  pname = "iocextract";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "InQuest";
    repo = "iocextract";
    tag = "v${version}";
    hash = "sha256-cCp9ug/TuVY1zL+kiDlFGBmfFJyAmVwxLD36WT0oRAE=";
  };

  propagatedBuildInputs = [
    regex
    requests
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # AssertionError: 'http://exampledotcom/test' != 'http://example.com/test'
    "test_refang_data"
  ];

  enabledTestPaths = [ "tests.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "iocextract" ];

  meta = {
    description = "Module to extract Indicator of Compromises (IOC)";
    homepage = "https://github.com/InQuest/iocextract";
    changelog = "https://github.com/InQuest/iocextract/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "iocextract";
  };
}
