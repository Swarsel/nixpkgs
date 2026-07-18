{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyshp";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "GeospatialPython";
    repo = "pyshp";
    tag = version;
    hash = "sha256-LsiTJpcO6KYZb3D6ysBWimFS1zEr0vQ9E9cOcC1jdLo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  disabledTests = [
    # Requires network access
    "test_reader_url"
  ];

  pyproject = true;
  pythonImportsCheck = [ "shapefile" ];

  meta = {
    description = "Python read/write support for ESRI Shapefile format";
    homepage = "https://github.com/GeospatialPython/pyshp";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
