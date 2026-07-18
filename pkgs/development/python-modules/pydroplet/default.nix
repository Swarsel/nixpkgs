{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pydroplet";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "Hydrific";
    repo = "pydroplet";
    tag = "v${version}";
    hash = "sha256-XLosly9Zyvp3Mfvj0mPORYJBNBkt8JPjlHuvHinZ39w=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydroplet" ];

  meta = {
    description = "Package to connect to a Droplet device";
    homepage = "https://github.com/Hydrific/pydroplet";
    changelog = "https://github.com/Hydrific/pydroplet/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
