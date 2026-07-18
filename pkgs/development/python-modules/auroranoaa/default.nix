{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "auroranoaa";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "djtimca";
    repo = "aurora-api";
    tag = version;
    hash = "sha256-bQDFSbYFsGtvPuJNMykynOpBTIeloUoCVRtIuHXR4n0=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "auroranoaa" ];

  meta = {
    description = "Python wrapper for the Aurora API";
    homepage = "https://github.com/djtimca/aurora-api";
    changelog = "https://github.com/djtimca/aurora-api/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
