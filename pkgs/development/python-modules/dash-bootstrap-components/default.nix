{
  lib,
  buildPythonPackage,
  dash,
  fetchPypi,
  hatchling,
}:

buildPythonPackage rec {
  pname = "dash-bootstrap-components";
  version = "2.0.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-wyBsCSN3S7xqbdqngiuNmqUyaw08HnzXlcyXUCX+JIQ=";
    pname = "dash_bootstrap_components";
  };

  # Tests a additional requirements
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ dash ];
  pyproject = true;
  pythonImportsCheck = [ "dash_bootstrap_components" ];

  meta = {
    description = "Bootstrap components for Plotly Dash";
    homepage = "https://github.com/facultyai/dash-bootstrap-components";
    changelog = "https://github.com/facultyai/dash-bootstrap-components/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
