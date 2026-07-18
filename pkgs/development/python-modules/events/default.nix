{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "events";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "pyeve";
    repo = "events";
    tag = "v${version}";
    hash = "sha256-GGhIKHbJ31IN0Uoe689X9V/MZvtseE47qx2CmM4MYUs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  enabledTestPaths = [ "events/tests/tests.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "events" ];

  meta = {
    description = "Bringing the elegance of C# EventHanlder to Python";
    homepage = "https://events.readthedocs.org";
    changelog = "https://github.com/pyeve/events/blob/v0.5/CHANGES";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
