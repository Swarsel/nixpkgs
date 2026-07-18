{
  lib,
  buildPythonPackage,
  fetchPypi,
  jsonschema,
  numpy,
  setuptools,
  svgwrite,
}:

buildPythonPackage rec {
  pname = "tskit";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-d6XzOSPVh1jsRg1A49aMWFyWVN29naYyYVXs82KQ0OA=";
  };

  postPatch = ''
    # build-time constriant, used to ensure forward and backward compat
    substituteInPlace pyproject.toml \
      --replace-fail "numpy>=2.0" "numpy"
  '';

  # Pypi does not include test folder and too complex to compile from GitHub source
  # will ask upstream to include tests in pypi
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    jsonschema
    numpy
    svgwrite
  ];

  pyproject = true;
  pythonImportsCheck = [ "tskit" ];

  meta = {
    description = "Tree sequence toolkit";
    homepage = "https://github.com/tskit-dev/tskit";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "tskit";
  };
}
