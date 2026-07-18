{
  lib,
  fetchFromGitHub,
  aiohttp,
  asynctest,
  buildPythonPackage,
  click,
  construct,
  fetchpatch,
  pycryptodomex,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyps4-2ndscreen";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "ktnrg45";
    repo = "pyps4-2ndscreen";
    tag = version;
    hash = "sha256-AXU9WJ7kT/0ev1Cn+CYhEieR7IM5VXebxQYWUS8bdds=";
  };

  patches = [
    # https://github.com/ktnrg45/pyps4-2ndscreen/pull/61
    (fetchpatch {
      hash = "sha256-igLa+DUvQWUZtrHiq9UXTSG2h7cktElaXbTsxYPEeLM=";
      name = "replace-async-timeout-with-asyncio.timeout.patch";
      url = "https://github.com/ktnrg45/pyps4-2ndscreen/commit/c3c89f9cce09d91e2b325474d28d7f1b3ccdf0f4.patch";
    })
  ];

  # All require asynctest, which is unsupported on 3.11+
  doCheck = false;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    asynctest
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    click
    construct
    pycryptodomex
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyps4_2ndscreen" ];

  meta = {
    description = "PS4 2nd Screen Python Library";
    homepage = "https://github.com/ktnrg45/pyps4-2ndscreen";
    changelog = "https://github.com/ktnrg45/pyps4-2ndscreen/releases/tag/${version}";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
