{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycryptodomex,
  pyopenssl,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "dsinternals";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "p0dalirius";
    repo = "pydsinternals";
    tag = finalAttrs.version;
    hash = "sha256-ZbYHO7It7R/Zh2dykTa4Ha4m2eyt9zkCzPyc/j79v6A=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    pyopenssl
    pycryptodomex
  ];

  enabledTestPaths = [ "tests/*.py" ];
  pyproject = true;
  pythonImportsCheck = [ "dsinternals" ];

  meta = {
    description = "Module to interact with Windows Active Directory";
    homepage = "https://github.com/p0dalirius/pydsinternals";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
