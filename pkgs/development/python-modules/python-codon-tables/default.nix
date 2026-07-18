{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-codon-tables";
  version = "0.1.18";

  src = fetchPypi {
    inherit version;
    hash = "sha256-c/VSmArSkq+46LzW3r+CQEG1mwp87ACbZ7EWkMOGOQc=";
    pname = "python_codon_tables";
  };

  # no tests in tarball
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "python_codon_tables" ];

  meta = {
    description = "Codon Usage Tables for Python, from kazusa.or.jp";
    homepage = "https://github.com/Edinburgh-Genome-Foundry/codon-usage-tables";
    changelog = "https://github.com/Edinburgh-Genome-Foundry/python_codon_tables/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
  };
}
