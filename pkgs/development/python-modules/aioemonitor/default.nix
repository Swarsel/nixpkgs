{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytest-raises,
  pytestCheckHook,
  setuptools,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioemonitor";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "aioemonitor";
    rev = "v${finalAttrs.version}";
    sha256 = "0h8zqqy8v8r1fl9bp3m8icr2sy44p0mbfl1hbb0zni17r9r50dhn";
  };

  postPatch = ''
    substituteInPlace setup.py --replace '"pytest-runner>=5.2",' ""
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-raises
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    xmltodict
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioemonitor" ];

  meta = {
    description = "Python client for SiteSage Emonitor";
    homepage = "https://github.com/bdraco/aioemonitor";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "my_example";
  };
})
