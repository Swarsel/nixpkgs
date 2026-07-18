{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  niapy,
  nltk,
  numpy,
  pandas,
  plotly,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  scikit-learn,
}:

buildPythonPackage rec {
  pname = "niaarm";
  # nixpkgs-update: no auto update
  version = "0.13.4";

  src = fetchFromGitHub {
    owner = "firefly-cpp";
    repo = "NiaARM";
    tag = version;
    hash = "sha256-524rJ5b9e0U1rqu1iCGMA3Tgnn9bO4biCC1FMoGNqms=";
  };

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Prevents 'Fatal Python error: Aborted' on darwin during checkPhase
    MPLBACKEND = "Agg";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    niapy
    nltk
    numpy
    pandas
    plotly
    scikit-learn
  ];

  disabledTests = [
    # Test requires extra nltk data dependency
    "test_text_mining"
  ];

  pyproject = true;
  pythonImportsCheck = [ "niaarm" ];

  pythonRelaxDeps = [
    "numpy"
    "plotly"
    "scikit-learn"
  ];

  meta = {
    description = "Minimalistic framework for Numerical Association Rule Mining";
    homepage = "https://github.com/firefly-cpp/NiaARM";
    changelog = "https://github.com/firefly-cpp/NiaARM/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ firefly-cpp ];
    mainProgram = "niaarm";
  };
}
