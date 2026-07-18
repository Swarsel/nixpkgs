{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "pycompliance";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "rhmdnd";
    repo = "pycompliance";
    rev = version;
    hash = "sha256-gCrKbKqRDlh9q9bETQ9NEPbf+40WKF1ltfBy6LYjlVw=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "pycompliance" ];

  meta = {
    description = "Simply library to represent compliance benchmarks as tree structures";
    homepage = "https://github.com/rhmdnd/pycompliance";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tochiaha ];
  };
}
