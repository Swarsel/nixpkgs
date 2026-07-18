{
  lib,
  fetchFromGitHub,
  biopython,
  buildPythonPackage,
  colorama,
  hatchling,
  numpy,
  pytest-repeat,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "affine-gaps";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "gata-bio";
    repo = "affine-gaps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WMH2wUqzA196FSe2TpfslQVW0PGwk7lGMRSKyfCG9rg=";
  };

  nativeCheckInputs = [
    biopython
    pytest-repeat
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    colorama
    numpy
  ];

  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "affine_gaps" ];

  meta = {
    homepage = "https://github.com/gata-bio/affine-gaps";
    changelog = "https://github.com/gata-bio/affine-gaps/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
    mainProgram = "affine-gaps";
  };
})
