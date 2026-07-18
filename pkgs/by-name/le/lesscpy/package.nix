{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "lesscpy";
  version = "0.15.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-EEXRepj2iGRsp1jf8lTm6cA3RWSOBRoIGwOVw7d8gkw=";
  };

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    ply
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "lesscpy" ];

  meta = {
    description = "Python LESS Compiler";
    homepage = "https://github.com/lesscpy/lesscpy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ s1341 ];
    mainProgram = "lesscpy";
  };
}
