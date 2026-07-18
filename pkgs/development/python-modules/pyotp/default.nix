{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyotp";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "pyauth";
    repo = "pyotp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ol7I3bj2bffKnO0r4VBOy/NvvK4pKbIul4FFlmF+wQU=";
  };

  nativeCheckInputs = [ unittestCheckHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyotp" ];

  meta = {
    description = "Python One Time Password Library";
    homepage = "https://github.com/pyauth/pyotp";
    changelog = "https://github.com/pyauth/pyotp/blob/v${finalAttrs.version}/Changes.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
