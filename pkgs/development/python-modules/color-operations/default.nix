{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # checks
  colormath,
  # build-system
  cython,
  # dependencies
  numpy,
  oldest-supported-numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "color-operations";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "vincentsarago";
    repo = "color-operations";
    tag = finalAttrs.version;
    hash = "sha256-hDxbyhelsl/EvsesD4Rux5CQM86squ4gHevVK/UP8Y8=";
  };

  nativeCheckInputs = [
    colormath
    pytestCheckHook
  ];

  preCheck = ''
    python setup.py build_ext --inplace
  '';

  build-system = [
    cython
    oldest-supported-numpy
    setuptools
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "color_operations" ];

  meta = {
    description = "Apply basic color-oriented image operations. Fork of rio-color";
    homepage = "https://github.com/vincentsarago/color-operations";
    changelog = "https://github.com/vincentsarago/color-operations/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    teams = [ lib.teams.geospatial ];
  };
})
