{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lib4sbom,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sbom2dot";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "anthonyharrison";
    repo = "sbom2dot";
    tag = "v${version}";
    hash = "sha256-g6IAGZCLRVxF0f6JEcxNaAKWYlTDt0zYSchsz6hDgdg=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    lib4sbom
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sbom2dot"
  ];

  meta = {
    description = "Create a dependency graph of the components within a SBOM";
    homepage = "https://github.com/anthonyharrison/sbom2dot";
    changelog = "https://github.com/anthonyharrison/sbom2dot/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "sbom2dot";
  };
}
