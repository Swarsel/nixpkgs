{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  colorlog,
  python-dateutil,
  setuptools,
  websockets,
}:

buildPythonPackage rec {
  pname = "livisi";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "planbnet";
    repo = "livisi";
    tag = "v${version}";
    hash = "sha256-5TRJfI4irg2/ZxpfgzShXE08HWU2aWLR8zGbrZKpwbc=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    colorlog
    python-dateutil
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "livisi" ];

  meta = {
    description = "Connection library for the abandoned Livisi Smart Home system";
    homepage = "https://github.com/planbnet/livisi";
    changelog = "https://github.com/planbnet/livisi/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
