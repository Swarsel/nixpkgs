{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "wakeonlan";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "remcohaszing";
    repo = "pywakeonlan";
    tag = version;
    hash = "sha256-AQjecGfcxI+zzUR6IO/iG/49QH1jClNYJFBEOABek5U=";
  };

  nativeBuildInputs = [ poetry-core ];
  nativeCheckInputs = [ pytestCheckHook ];
  enabledTestPaths = [ "test_wakeonlan.py" ];
  pyproject = true;
  pythonImportsCheck = [ "wakeonlan" ];

  meta = {
    description = "Python module for wake on lan";
    homepage = "https://github.com/remcohaszing/pywakeonlan";
    changelog = "https://github.com/remcohaszing/pywakeonlan/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "wakeonlan";
  };
}
