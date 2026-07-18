{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytube";
  version = "15.0.0";

  src = fetchFromGitHub {
    owner = "pytube";
    repo = "pytube";
    rev = "v${version}";
    hash = "sha256-Nvs/YlOjk/P5nd1kpUnCM2n6yiEaqZP830UQI0Ug1rk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTestPaths = [
    "tests/test_extract.py"
    "tests/test_query.py"
    "tests/test_streams.py"
    "tests/test_main.py"
  ];

  disabledTests = [ "test_streaming" ];
  format = "setuptools";
  pythonImportsCheck = [ "pytube" ];

  meta = {
    description = "Python 3 library for downloading YouTube Videos";
    homepage = "https://github.com/nficano/pytube";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "pytube";
  };
}
