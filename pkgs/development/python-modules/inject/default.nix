{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "inject";
  version = "5.4.1";

  src = fetchFromGitHub {
    owner = "ivankorobkov";
    repo = "python-inject";
    tag = "v${finalAttrs.version}";
    hash = "sha256-thVgKkpFtMwTMfeQ2r7xMvLtzBFJ/xIy6aUTq3400VA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;
  pythonImportsCheck = [ "inject" ];

  meta = {
    description = "Python dependency injection framework";
    homepage = "https://github.com/ivankorobkov/python-inject";
    changelog = "https://github.com/ivankorobkov/python-inject/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ PerchunPak ];
  };
})
