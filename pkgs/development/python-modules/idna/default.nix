{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "idna";
  version = "3.18";

  src = fetchFromGitHub {
    owner = "kjd";
    repo = "idna";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9nLy/9PNuLSQJsf4Jes0uN695+LGjz2LXlfiZxxvGV4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "idna" ];

  meta = {
    description = "Internationalized Domain Names in Applications (IDNA)";
    homepage = "https://github.com/kjd/idna/";
    changelog = "https://github.com/kjd/idna/blob/${finalAttrs.src.tag}/HISTORY.md";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
