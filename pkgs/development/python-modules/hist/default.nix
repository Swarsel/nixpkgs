{
  lib,
  boost-histogram,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  histoprint,
  numpy,
  pytest-mpl,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "hist";
  version = "2.10.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-3sjmrHmm1k7Ihzzzaz7wOUx5r/Ow6Kvtcf3Hf9xCGy4=";
  };

  checkInputs = [
    pytestCheckHook
    pytest-mpl
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    boost-histogram
    histoprint
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "hist" ];

  meta = {
    description = "Histogramming for analysis powered by boost-histogram";
    homepage = "https://hist.readthedocs.io/";
    changelog = "https://github.com/scikit-hep/hist/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ veprbl ];
    mainProgram = "";
  };
})
