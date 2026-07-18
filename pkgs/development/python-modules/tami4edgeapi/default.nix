{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyjwt,
  pypasser,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tami4edgeapi";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "Guy293";
    repo = "Tami4EdgeAPI";
    tag = "v${version}";
    hash = "sha256-rhJ8L6qLDnO50Xp2eqquRinDTQjMxWVSjNL5GQI1gvM=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pyjwt
    pypasser
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "Tami4EdgeAPI" ];

  meta = {
    description = "Python API client for Tami4 Edge / Edge+ devices";
    homepage = "https://github.com/Guy293/Tami4EdgeAPI";
    changelog = "https://github.com/Guy293/Tami4EdgeAPI/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
