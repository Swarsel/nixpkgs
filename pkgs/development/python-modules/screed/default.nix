{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "screed";
  version = "1.1.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-N+gWl8fbqVoFNVTltahq/zKXBeHPXfxee42lht7gcrg=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  checkInputs = [ pytestCheckHook ];

  # These tests use the screed CLI and make assumptions on how screed is
  # installed that break with nix. Can be enabled when upstream is fixed.
  disabledTests = [
    "Test_convert_shell"
    "Test_fa_shell_command"
    "Test_fq_shell_command"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "screed" ];

  meta = {
    description = "Simple read-only sequence database, designed for short reads";
    homepage = "https://pypi.org/project/screed/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ luizirber ];
    mainProgram = "screed";
  };
}
