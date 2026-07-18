{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hl7";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "johnpaulett";
    repo = "python-hl7";
    tag = version;
    hash = "sha256-9uFdyL4+9KSWXflyOMOeUudZTv4NwYPa0ADNTmuVbqo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "hl7" ];

  meta = {
    description = "Simple library for parsing messages of Health Level 7 (HL7) version 2.x into Python objects";
    homepage = "https://python-hl7.readthedocs.org";
    changelog = "https://python-hl7.readthedocs.io/en/latest/changelog.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "mllp_send";
  };
}
