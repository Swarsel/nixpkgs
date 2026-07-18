{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiopegelonline";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "mib1185";
    repo = "aiopegelonline";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uV4qVCj28wgraWmWhyqN98/SaVDJFuJ30ugViKrl2us=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==82.0.1" "setuptools"
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aiopegelonline" ];

  meta = {
    description = "Library to retrieve data from PEGELONLINE";
    homepage = "https://github.com/mib1185/aiopegelonline";
    changelog = "https://github.com/mib1185/aiopegelonline/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
