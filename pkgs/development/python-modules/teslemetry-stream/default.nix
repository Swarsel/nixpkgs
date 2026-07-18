{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "teslemetry-stream";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Teslemetry";
    repo = "python-teslemetry-stream";
    tag = "v${version}";
    hash = "sha256-FMFzH6b3A1tILwgGOlQHUl/BCvtdZLmHTkyt+/PYBU8=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "teslemetry_stream" ];

  meta = {
    description = "Python library for the Teslemetry Streaming API";
    homepage = "https://github.com/Teslemetry/python-teslemetry-stream";
    changelog = "https://github.com/Teslemetry/python-teslemetry-stream/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
