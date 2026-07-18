{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  git, # shells out to git
  hatchling,
  incremental,
  jinja2,
  mock,
  pytestCheckHook,
  twisted,
}:

buildPythonPackage rec {
  pname = "towncrier";
  version = "25.8.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7vFtKfgxrVers64yoFZXOYZiGfHr+90pfTKJTrmUDrE=";
  };

  nativeCheckInputs = [
    git
    mock
    twisted
    pytestCheckHook
  ];

  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  build-system = [ hatchling ];

  dependencies = [
    click
    incremental
    jinja2
  ];

  pyproject = true;
  pythonImportsCheck = [ "towncrier" ];

  meta = {
    description = "Utility to produce useful, summarised news files";
    homepage = "https://github.com/twisted/towncrier/";
    changelog = "https://github.com/twisted/towncrier/blob/${version}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "towncrier";
  };
}
