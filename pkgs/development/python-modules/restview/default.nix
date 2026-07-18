{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  packaging,
  pygments,
  pytestCheckHook,
  readme-renderer,
  setuptools,
}:

buildPythonPackage rec {
  pname = "restview";
  version = "3.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-i011oL7Xa2e0Vu9wEfTrbJilVsn4N2Qt8iAscxL8zBo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    docutils
    readme-renderer
    packaging
    pygments
  ];

  disabledTests = [
    # Tests are comparing output
    "rest_to_html"
  ];

  pyproject = true;
  pythonImportsCheck = [ "restview" ];
  pythonRelaxDeps = [ "readme_renderer" ];

  meta = {
    description = "ReStructuredText viewer";
    homepage = "https://mg.pov.lt/restview/";
    changelog = "https://github.com/mgedmin/restview/blob/${version}/CHANGES.rst";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ koral ];
    mainProgram = "restview";
  };
}
