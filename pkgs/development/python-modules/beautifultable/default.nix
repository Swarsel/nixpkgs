{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  wcwidth,
}:

buildPythonPackage (finalAttrs: {
  pname = "beautifultable";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "pri22296";
    repo = "beautifultable";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/SReCEvSwiNjBoz/3tGJ9zUNBAag4mLsHlUXwm47zCw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ wcwidth ];
  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "beautifultable" ];

  meta = {
    description = "Python package for printing visually appealing tables";
    homepage = "https://github.com/pri22296/beautifultable";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
