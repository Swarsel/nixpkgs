{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyclipper";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "fonttools";
    repo = "pyclipper";
    tag = version;
    hash = "sha256-mh+F3iFCItmLbV6bF7Mi5IaWwjcKrE9Nk6lxglyFUg4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyclipper" ];

  meta = {
    description = "Cython wrapper for clipper library";
    homepage = "https://github.com/fonttools/pyclipper";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthuszagh ];
  };
}
