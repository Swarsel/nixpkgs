{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dnspython,
  ifaddr,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aioice";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "aiortc";
    repo = "aioice";
    tag = version;
    hash = "sha256-UEXkTxcpe6mlA2FmMSfDmtcEYE9zwuitpi2Eh188xZc=";
  };

  doCheck = true;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    dnspython
    ifaddr
  ];

  disabledTestPaths = [
    # Network tests failing
    "tests/test_ice.py"
    "tests/test_mdns.py"
    "tests/test_turn.py"
    "tests/test_ice_trickle.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "aioice"
  ];

  meta = {
    description = "Asyncio-based Interactive Connectivity Establishment (RFC 5245)";
    homepage = "https://github.com/aiortc/aioice";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ gesperon ];
  };
}
