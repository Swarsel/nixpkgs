{
  lib,
  fetchFromGitHub,
  betamax,
  buildPythonPackage,
  pytestCheckHook,
  requests-toolbelt,
  setuptools,
}:

buildPythonPackage rec {
  pname = "betamax-matchers";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "betamaxpy";
    repo = "betamax_matchers";
    tag = version;
    hash = "sha256-BV9DOfZLDAZIr2E75l988QxFWWvazBL9VttxGFIez1M=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    betamax
    requests-toolbelt
  ];

  pyproject = true;
  pythonImportsCheck = [ "betamax_matchers" ];

  meta = {
    description = "Group of experimental matchers for Betamax";
    homepage = "https://github.com/sigmavirus24/betamax_matchers";
    changelog = "https://github.com/betamaxpy/betamax_matchers/blob/${version}/HISTORY.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pSub ];
  };
}
