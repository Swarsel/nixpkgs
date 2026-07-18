{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  pyjwt,
  setuptools,
  websockets,
  yarl,
}:

buildPythonPackage rec {
  pname = "elmax-api";
  version = "0.0.6.4rc0";

  src = fetchFromGitHub {
    owner = "albertogeniola";
    repo = "elmax-api";
    tag = "v${version}";
    hash = "sha256-BYVfP8B+p4J4gW+64xh9bT9sDcu/lk0R+MvLsYLwRfQ=";
  };

  # Test require network access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    httpx
    pyjwt
    websockets
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "elmax_api" ];

  meta = {
    description = "Python library for interacting with the Elmax cloud";
    homepage = "https://github.com/albertogeniola/elmax-api";
    changelog = "https://github.com/albertogeniola/elmax-api/releases/tag/v${version}";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
