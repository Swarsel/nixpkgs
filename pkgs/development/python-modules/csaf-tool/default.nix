{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packageurl-python,
  rich,
  setuptools,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "csaf-tool";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "anthonyharrison";
    repo = "csaf";
    tag = version;
    hash = "sha256-LR6r03z0nvvAQgFHaTWfukoJmLZ6SLPXfbp/G8N/HtM=";
  };

  # has not tests
  doCheck = false;
  nativeCheckInputs = [ versionCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    packageurl-python
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "csaf" ];

  meta = {
    description = "CSAF generator and validator";
    homepage = "https://github.com/anthonyharrison/csaf";
    changelog = "https://github.com/anthonyharrison/csaf/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ teatwig ];
  };
}
