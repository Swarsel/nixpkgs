{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defcon,
  fontpens,
  fonttools,
  pyclipper,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "booleanoperations";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "typemytype";
    repo = "booleanOperations";
    tag = finalAttrs.version;
    hash = "sha256-IJyb6g2xwWj82Vm33Mtkqen1X/w0tSaP+Q/DtFc8Dd4=";
  };

  nativeCheckInputs = [
    defcon
    fontpens
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fonttools
    pyclipper
  ];

  pyproject = true;
  pythonImportsCheck = [ "booleanOperations" ];

  meta = {
    description = "Boolean operations on paths";
    homepage = "https://github.com/typemytype/booleanOperations";
    changelog = "https://github.com/typemytype/booleanOperations/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
