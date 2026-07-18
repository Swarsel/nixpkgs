{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  python-socketio-v4,
  setuptools,
  websocket-client,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pycontrol4";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "lawtancool";
    repo = "pyControl4";
    tag = "v${version}";
    hash = "sha256-4qgyn2ekxo0pjPixfNpRqHE+jgsNQGk9fbESbUTDxMg=";
  };

  # tests access network
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    xmltodict
    python-socketio-v4
    websocket-client
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyControl4.account"
    "pyControl4.alarm"
    "pyControl4.director"
    "pyControl4.light"
  ];

  meta = {
    description = "Python 3 asyncio package for interacting with Control4 systems";
    homepage = "https://github.com/lawtancool/pyControl4";
    changelog = "https://github.com/lawtancool/pyControl4/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
