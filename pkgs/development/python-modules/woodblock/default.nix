{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  multimethod,
  numpy,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "woodblock";
  version = "0.1.7";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-wDR+zpILcAnZRVGYOgH0LbApIMqNew/zbSSjN+LJN/c=";
  };

  # no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    click
    multimethod
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "woodblock" ];

  meta = {
    description = "Framework to generate file carving test data";
    homepage = "https://github.com/fkie-cad/woodblock";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "woodblock";
  };
})
