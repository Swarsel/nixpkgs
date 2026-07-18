{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flake8,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "flake8-deprecated";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "gforcada";
    repo = "flake8-deprecated";
    tag = version;
    hash = "sha256-KF0hWhMZEWuSPUyfStayNa5Nfss9NpTvMXPeemWbQXU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  dependencies = [ flake8 ];
  enabledTestPaths = [ "run_tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "flake8_deprecated" ];

  meta = {
    description = "Flake8 plugin that warns about deprecated method calls";
    homepage = "https://github.com/gforcada/flake8-deprecated";
    changelog = "https://github.com/gforcada/flake8-deprecated/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ lopsided98 ];
  };
}
