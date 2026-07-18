{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  flit-core,
  pyyaml,
  sphinx,
  sphinx-multitoc-numbering,
}:

buildPythonPackage rec {
  pname = "sphinx-external-toc";
  version = "1.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+BgzhlAG9rSpslUKJHSm49fn8ssjuiMwkmBXfqZVUvY=";
    pname = "sphinx_external_toc";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    click
    pyyaml
    sphinx
    sphinx-multitoc-numbering
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinx_external_toc" ];

  meta = {
    description = "Sphinx extension that allows the site-map to be defined in a single YAML file";
    homepage = "https://github.com/executablebooks/sphinx-external-toc";
    changelog = "https://github.com/executablebooks/sphinx-external-toc/raw/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "sphinx-etoc";
  };
}
