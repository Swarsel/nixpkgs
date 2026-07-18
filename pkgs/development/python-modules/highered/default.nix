{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  # dependencies
  pyhacrf-datamade,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  unstableGitUpdater,
}:

buildPythonPackage {
  pname = "highered";
  version = "0.2.1-unstable-2020-03-31";

  src = fetchFromGitHub {
    owner = "dedupeio";
    repo = "highered";
    rev = "5e6e505e182ff91b1620535a491ad4a3d98ef71e";
    hash = "sha256-sDOAB0QabJ/WJYSIZ31J12kSDQADQUilE2SmGPjXmZo=";
  };

  # No tests in repository
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    pyhacrf-datamade
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "highered"
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Learnable edit distance using CRF (Conditional Random Fields)";
    homepage = "https://github.com/dedupeio/highered";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ daniel-fahey ];
  };
}
