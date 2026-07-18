{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyyaml,
  rst2pdf,
  setuptools,
  sphinx,
}:
buildPythonPackage rec {
  pname = "sphinxcontrib-mermaid";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-z099RT0AETLqul0f31PUIEnwLpEyE8+DN0J0g7/KJvQ=";
    pname = "sphinxcontrib_mermaid";
  };

  build-system = [ setuptools ];

  dependencies = [
    sphinx
    pyyaml
    rst2pdf
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinxcontrib.mermaid" ];

  meta = {
    description = "Mermaid diagrams in yours sphinx powered docs";
    homepage = "https://github.com/mgaitan/sphinxcontrib-mermaid";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
