{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pybibget";
  version = "0.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-M6CIctTOVn7kIPmsoHQmYl2wQaUzfel7ryw/3ebQitg=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    lxml
    httpx
    appdirs
    aiolimiter
    pybtex
    pylatexenc
    numpy
    networkx
    requests
  ];

  # Tests for this application do not run on NixOS, and binaries were
  # manually tested instead
  doCheck = false;

  build-system = [
    python3.pkgs.setuptools
  ];

  pyproject = true;

  meta = {
    description = "Command line utility to automatically retrieve BibTeX citations from MathSciNet, arXiv, PubMed and doi.org";
    homepage = "https://github.com/wirhabenzeit/pybibget";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vasissualiyp ];
  };
})
