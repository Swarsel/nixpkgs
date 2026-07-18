{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # reverse dependencies
  jinja2,
  mkdocs,
  # tests
  pytestCheckHook,
  quart,
  # build-system
  setuptools,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "markupsafe";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "pallets";
    repo = "markupsafe";
    tag = version;
    hash = "sha256-2d64cItemqVM25WJIKrjExKz6v4UW2wVxM6phH1g1sE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "markupsafe" ];

  passthru.tests = {
    inherit
      jinja2
      mkdocs
      quart
      werkzeug
      ;
  };

  meta = {
    description = "Implements a XML/HTML/XHTML Markup safe string";
    homepage = "https://palletsprojects.com/p/markupsafe/";

    changelog = "https://markupsafe.palletsprojects.com/page/changes/#version-${
      lib.replaceStrings [ "." ] [ "-" ] version
    }";

    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
