{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cairosvg,
  ipywidgets,
  metakernel,
  numpy,
  setuptools,
  svgwrite,
}:

buildPythonPackage (finalAttrs: {
  pname = "calysto";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "Calysto";
    repo = "calysto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lr/cHFshpFs/PGMCsa3FKMRPTP+eE9ziH5XCpV+KzO8=";
  };

  # there are no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    metakernel
    svgwrite
    ipywidgets
    cairosvg
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "calysto" ];

  meta = {
    description = "Tools for Jupyter and Python";
    homepage = "https://github.com/Calysto/calysto";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
})
