{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dash,
  dash-bootstrap-components,
  numpy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dash-bootstrap-templates";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "AnnMarieW";
    repo = "dash-bootstrap-templates";
    tag = "V${version}";
    hash = "sha256-B7iyN4sJA6DmoLf3DpFEONDe5tUd4cBlDIH4E7JtULk=";
  };

  # There are no tests.
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dash
    dash-bootstrap-components
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "dash_bootstrap_templates" ];

  meta = {
    description = "Collection of 52 Plotly figure templates with a Bootstrap theme";
    homepage = "https://github.com/AnnMarieW/dash-bootstrap-templates";
    changelog = "https://github.com/AnnMarieW/dash-bootstrap-templates/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
