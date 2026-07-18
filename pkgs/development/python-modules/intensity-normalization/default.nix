{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  nibabel,
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  scikit-fuzzy,
  scipy,
}:

buildPythonPackage (finalAttrs: {
  pname = "intensity-normalization";
  version = "3.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-d5f+Ug/ta9RQjk3JwHmVJQr8g93glzf7IcmLxLeA1tQ=";
    pname = "intensity_normalization";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ hatchling ];

  dependencies = [
    nibabel
    numpy
    scikit-fuzzy
    scipy
  ];

  enabledTestPaths = [ "tests" ];
  pyproject = true;

  pythonImportsCheck = [
    "intensity_normalization"
    "intensity_normalization.adapters"
    "intensity_normalization.domain"
    "intensity_normalization.normalizers"
    "intensity_normalization.services"
  ];

  meta = {
    description = "MRI intensity normalization tools";
    homepage = "https://github.com/jcreinhold/intensity-normalization";
    changelog = "https://github.com/jcreinhold/intensity-normalization/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "intensity-normalize";
  };
})
