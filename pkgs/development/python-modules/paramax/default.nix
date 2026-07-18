{
  lib,
  fetchFromGitHub,
  # tests
  beartype,
  buildPythonPackage,
  # dependencies
  equinox,
  # build-system
  hatchling,
  jax,
  jaxtyping,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "paramax";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "danielward27";
    repo = "paramax";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UPSnFtypQYtnDRl2GCoy+OQ8Ws7eX+iPsd8WWBsgmlo=";
  };

  nativeCheckInputs = [
    beartype
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    equinox
    jax
    jaxtyping
  ];

  pyproject = true;
  pythonImportsCheck = [ "paramax" ];

  meta = {
    description = "Small library of paramaterizations and parameter constraints for PyTrees";
    homepage = "https://github.com/danielward27/paramax";
    changelog = "https://github.com/danielward27/paramax/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
