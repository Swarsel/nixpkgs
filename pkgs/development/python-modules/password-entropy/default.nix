{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "password-entropy";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "alistratov";
    repo = "password-entropy-py";
    tag = version;
    hash = "sha256-w721Y/zRMH3fsU0XtaGSDoj1GKqOW/IOGUfimoq4r2E=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    flit-core
  ];

  pyproject = true;

  pythonImportsCheck = [
    "data_password_entropy"
  ];

  meta = {
    description = "Calculate password strength";
    homepage = "https://github.com/alistratov/password-entropy-py";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
