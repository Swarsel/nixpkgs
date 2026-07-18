{
  lib,
  fetchFromGitHub,
  atomicwrites,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fpyutils";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "frnmst";
    repo = "fpyutils";
    tag = version;
    hash = "sha256-VVR1zsejO6kHlMjqqlftDKu3/SyDzgPov9f48HYL/Bk=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    atomicwrites
    requests
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # Don't run test which requires bash
    "test_execute_command_live_output"
  ];

  enabledTestPaths = [ "fpyutils/tests/*.py" ];
  pyproject = true;
  pythonImportsCheck = [ "fpyutils" ];

  meta = {
    description = "Collection of useful non-standard Python functions";
    homepage = "https://github.com/frnmst/fpyutils";
    changelog = "https://blog.franco.net.eu.org/software/fpyutils-${version}/release.html";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
