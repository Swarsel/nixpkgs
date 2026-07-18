{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pysigma,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pysigma-pipeline-sysmon";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "SigmaHQ";
    repo = "pySigma-pipeline-sysmon";
    tag = "v${version}";
    hash = "sha256-W0KNsawcJ1XmQ2Tmh+aD8EUL2LenCQUEUgx9shQhRDQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ pysigma ];
  pyproject = true;
  pythonImportsCheck = [ "sigma.pipelines.sysmon" ];

  meta = {
    description = "Library to support Sysmon pipeline for pySigma";
    homepage = "https://github.com/SigmaHQ/pySigma-pipeline-sysmon";
    changelog = "https://github.com/SigmaHQ/pySigma-pipeline-sysmon/releases/tag/${src.tag}";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
