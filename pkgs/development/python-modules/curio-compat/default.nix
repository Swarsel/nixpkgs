{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "curio-compat";
  version = "1.6.7";

  src = fetchFromGitHub {
    owner = "klen";
    repo = "curio";
    tag = version;
    hash = "sha256-Crd9r4Icwga85wvtXaePbE56R192o+FXU9Zn+Lc7trI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # contacts google.com
    "test_ssl_outgoing"
  ];

  pyproject = true;
  pythonImportsCheck = [ "curio" ];

  meta = {
    description = "Coroutine-based library for concurrent systems programming";
    homepage = "https://github.com/klen/curio";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
