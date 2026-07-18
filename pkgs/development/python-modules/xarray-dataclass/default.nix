{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  numpy,
  pytestCheckHook,
  typing-extensions,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "xarray-dataclass";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "xarray-contrib";
    repo = "xarray-dataclass";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NHJvrkoRhq5cPSBBMWzrWVn+3sPvveMRgTXc/NdLfuA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
  ];

  dependencies = [
    numpy
    typing-extensions
    xarray
  ];

  pyproject = true;
  pythonImportsCheck = [ "xarray_dataclass" ];
  pythonRelaxDeps = [ "xarray" ];

  meta = {
    description = "Xarray data creation made easy by dataclass";
    homepage = "https://xarray-contrib.github.io/xarray-dataclass";
    changelog = "https://github.com/xarray-contrib/xarray-dataclass/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
