{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyhibp";
  version = "4.2.0";

  src = fetchFromGitLab {
    owner = "pyHIBP";
    repo = "pyHIBP";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2LJA989hpG5X6o+zCTSU0RRd0Z4zd29RAtp/jBW8Clo=";
    group = "kitsunix";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ requests ];

  disabledTests = [
    # All require internet access
    "TestIsPasswordBreached"
    "TestSuffixSearch"
    "TestGetAllBreaches"
    "TestGetSingleBreach"
    "TestGetDataClasses"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyhibp" ];

  meta = {
    description = "Python interface to Troy Hunt's 'Have I Been Pwned?' public API";
    homepage = "https://gitlab.com/kitsunix/pyHIBP/pyHIBP";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
  };
})
