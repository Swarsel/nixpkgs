{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinx-reredirects";
  version = "1.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+5sZUzWrFLQ/gnMofQx+62N7psVsZlgcEbRyAvZxiyk=";
    pname = "sphinx_reredirects";
  };

  build-system = [
    flit-core
  ];

  dependencies = [
    sphinx
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sphinx_reredirects"
  ];

  meta = {
    description = "Handles redirects for moved pages in Sphinx documentation projects";
    homepage = "https://pypi.org/project/sphinx-reredirects";

    license = with lib.licenses; [
      bsd3
      mit
    ];

    maintainers = [ ];
  };
}
