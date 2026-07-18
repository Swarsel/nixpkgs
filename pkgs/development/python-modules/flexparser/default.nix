{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # checks
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  # dependencies
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "flexparser";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "hgrecco";
    repo = "flexparser";
    rev = version;
    hash = "sha256-0Ocp4GsrnzkpSqnP+AK5OxJ3KyUf5Uc6CegDXpRYRqo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "flexparser" ];

  meta = {
    description = "Parsing made fun ... using typing";
    homepage = "https://github.com/hgrecco/flexparser";
    changelog = "https://github.com/hgrecco/flexparser/blob/${src.rev}/CHANGES";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
