{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  fetchpatch2,
  netifaces,
  poetry-core,
  python-engineio-v3,
  python-socketio-v4,
}:

buildPythonPackage rec {
  pname = "sisyphus-control";
  version = "3.1.4";

  src = fetchFromGitHub {
    owner = "jkeljo";
    repo = "sisyphus-control";
    tag = "v${version}";
    hash = "sha256-1/trJ/mfiXljNt7ZIBwQ45mIBbqg68e29lvVsPDPzoU=";
  };

  patches = [
    # https://github.com/jkeljo/sisyphus-control/pull/9
    (fetchpatch2 {
      hash = "sha256-573YLPrNbbMXSrZ3gK8cmHmuk2+UeggcKL/+eo4pgrs=";
      name = "specify-build-system.patch";
      url = "https://github.com/jkeljo/sisyphus-control/commit/dd48079e03a53cdb3af721de0d307209286c38f0.patch";
    })
  ];

  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    netifaces
    python-engineio-v3
    python-socketio-v4
  ];

  pyproject = true;
  pythonImportsCheck = [ "sisyphus_control" ];

  meta = {
    description = "Control your Sisyphus Kinetic Art Table";
    homepage = "https://github.com/jkeljo/sisyphus-control";
    changelog = "https://github.com/jkeljo/sisyphus-control/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
