{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  ipykernel,
  jupytext,
  mkdocs,
  mkdocs-material,
  nbconvert,
  pygments,
  pytest-cov-stub,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "mkdocs-jupyter";
  version = "0.26.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-fIDA05U96R5bQKDTIJIzeVyPgAJDqymOTsOOBQTtpjA=";
    pname = "mkdocs_jupyter";
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    ipykernel
    jupytext
    mkdocs
    mkdocs-material
    nbconvert
    pygments
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkdocs_jupyter" ];

  pythonRelaxDeps = [
    "ipykernel"
    "nbconvert"
  ];

  meta = {
    description = "Use Jupyter Notebook in mkdocs";
    homepage = "https://github.com/danielfrg/mkdocs-jupyter";
    changelog = "https://github.com/danielfrg/mkdocs-jupyter/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ net-mist ];
  };
}
