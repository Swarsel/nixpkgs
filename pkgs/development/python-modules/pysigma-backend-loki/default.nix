{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pysigma,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pysigma-backend-loki";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "pySigma-backend-loki";
    tag = "v${version}";
    hash = "sha256-36fdFuvUSAeGyV5z55/MGcdMiCNz12EbiRw87MjmaKY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ pysigma ];

  disabledTestPaths = [
    # Tests are out-dated
    "tests/test_backend_loki_field_modifiers.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sigma.backends.loki" ];
  pythonRelaxDeps = [ "pysigma" ];

  meta = {
    description = "Library to support the loki backend for pySigma";
    homepage = "https://github.com/grafana/pySigma-backend-loki";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
