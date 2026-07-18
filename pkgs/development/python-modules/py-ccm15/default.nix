{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  httpx,
  pytestCheckHook,
  setuptools,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "py-ccm15";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "ocalvo";
    repo = "py-ccm15";
    # Upstream does not have a tag for this release and this is the exact release commit
    # Therefore it should not be marked unstable
    # upstream issue: https://github.com/ocalvo/py-ccm15/issues/10
    tag = "v${version}";
    hash = "sha256-qEowsu7ebnD5eCR7SiWEqLwR3yqoqOnuw4wSQm4rmHQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    httpx
    xmltodict
    aiohttp
  ];

  disabledTests = [
    # tests use outdated function signature
    "test_async_set_state"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ccm15" ];

  meta = {
    description = "Python Library to access a Midea CCM15 data converter";
    homepage = "https://github.com/ocalvo/py-ccm15";
    changelog = "https://github.com/ocalvo/py-ccm15/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
