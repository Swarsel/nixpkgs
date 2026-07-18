{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # depenencies
  laszip,
  lazrs,
  numpy,
  # tests
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "laspy";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "laspy";
    repo = "laspy";
    tag = finalAttrs.version;
    hash = "sha256-/wvwUE+lzBgAZVtLB05Fpuq0ElajMxWqCIa1Y3sjB5k=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    numpy
    laszip
    lazrs # much faster laz reading, see https://laspy.readthedocs.io/en/latest/installation.html#laz-support
  ];

  pyproject = true;

  pythonImportsCheck = [
    "laspy"
    # `laspy` supports multiple backends and detects them dynamically.
    # We check their importability to make sure they are all working.
    "laszip"
    "lazrs"
  ];

  meta = {
    description = "Interface for reading/modifying/creating .LAS LIDAR files";
    homepage = "https://github.com/laspy/laspy";
    changelog = "https://github.com/laspy/laspy/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "laspy";
    teams = [ lib.teams.geospatial ];
  };
})
