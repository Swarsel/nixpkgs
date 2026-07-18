{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  numpy,
  # tests
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  svgwrite,
}:

buildPythonPackage rec {
  pname = "svgpathtools";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "mathandy";
    repo = "svgpathtools";
    tag = "v${version}";
    hash = "sha256-OGengjPIEuxDYHqzFUBbYcVs9RjBSKSd1NNjx/KqnSk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    scipy
    svgwrite
  ];

  pyproject = true;

  pythonImportsCheck = [
    "svgpathtools"
  ];

  meta = {
    description = "Collection of tools for manipulating and analyzing SVG Path objects and Bezier curves";
    homepage = "https://github.com/mathandy/svgpathtools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
