{
  lib,
  fetchFromGitHub,
  aiohttp,
  beautifulsoup4,
  buildPythonPackage,
  cryptography,
  orjson,
  pycryptodome,
  pytest-cov-stub,
  pytestCheckHook,
  segno,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiovodafone";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "chemelli74";
    repo = "aiovodafone";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KKd8dOabm/6YksBG6+51zYUsgiA4wFW6dGe2tiX3fQA=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    beautifulsoup4
    cryptography
    orjson
    pycryptodome
    segno
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiovodafone" ];

  meta = {
    description = "Library to control Vodafon Station";
    homepage = "https://github.com/chemelli74/aiovodafone";
    changelog = "https://github.com/chemelli74/aiovodafone/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
