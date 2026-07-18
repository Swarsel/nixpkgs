{
  lib,
  fetchFromGitHub,
  asysocks,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "unidns";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "skelsec";
    repo = "unidns";
    tag = finalAttrs.version;
    hash = "sha256-uhTb27HeBaoI4yURpNf1+D6bWIXSsmYzUyk0RJmgbjQ=";
  };

  # No tests provided
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    asysocks
  ];

  pyproject = true;

  pythonImportsCheck = [
    "unidns"
  ];

  pythonRelaxDeps = [
    "asysocks"
  ];

  meta = {
    description = "Basic async DNS library";
    homepage = "https://github.com/skelsec/unidns";
    changelog = "https://github.com/skelsec/unidns/releases/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
