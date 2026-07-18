{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ihm,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "modelcif";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "ihmwg";
    repo = "python-modelcif";
    tag = finalAttrs.version;
    hash = "sha256-4iAFXL+3/HOP2wmO0SoXAGPRrkoaITStDQKvhKAOjTA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [ ihm ];

  disabledTests = [
    # require network access
    "test_associated_example"
    "test_validate_mmcif_example"
    "test_validate_modbase_example"
  ];

  pyproject = true;
  pythonImportsCheck = [ "modelcif" ];

  meta = {
    description = "Python package for handling ModelCIF mmCIF and BinaryCIF files";
    homepage = "https://github.com/ihmwg/python-modelcif";
    changelog = "https://github.com/ihmwg/python-modelcif/blob/${finalAttrs.src.tag}/ChangeLog.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
})
