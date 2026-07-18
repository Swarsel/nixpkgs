{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  flit-core,
  jinja2,
  requests,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-confluencebuilder";
  version = "3.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5eBr1+QqRDKwXZDChQG5Wf5p79zqvCGyCUp3KgNg1yE=";
    pname = "sphinxcontrib_confluencebuilder";
  };

  # Tests are disabled due to a circular dependency on Sphinx
  doCheck = false;
  build-system = [ flit-core ];

  dependencies = [
    docutils
    sphinx
    requests
    jinja2
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinxcontrib.confluencebuilder" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Confluence builder for sphinx";
    homepage = "https://github.com/sphinx-contrib/confluencebuilder";
    changelog = "https://github.com/sphinx-contrib/confluencebuilder/blob/v${version}/CHANGES.rst";
    license = lib.licenses.bsd1;
    maintainers = with lib.maintainers; [ graysonhead ];
    mainProgram = "sphinx-build-confluence";
  };
}
