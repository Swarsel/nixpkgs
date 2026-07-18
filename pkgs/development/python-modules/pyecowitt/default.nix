{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyecowitt";
  version = "0.21";

  src = fetchFromGitHub {
    owner = "garbled1";
    repo = "pyecowitt";
    tag = version;
    hash = "sha256-5VdVo6j2HZXSCWU4NvfWzyS/KJfVb7N1KSMeu8TvWaQ=";
  };

  # Project thas no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pyecowitt" ];

  meta = {
    description = "Python module for the EcoWitt Protocol";
    homepage = "https://github.com/garbled1/pyecowitt";
    changelog = "https://github.com/garbled1/pyecowitt/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
