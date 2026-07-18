{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "aioweenect";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "eifinger";
    repo = "aioweenect";
    tag = "v${version}";
    hash = "sha256-YaIOCBBfL2lC6EPwBShVbPXiVlic7zK6pNOWjBJ/Y7I=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--asyncio-mode=auto" ""
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aioweenect" ];
  pythonRelaxDeps = [ "aiohttp" ];

  meta = {
    description = "Library for the weenect API";
    homepage = "https://github.com/eifinger/aioweenect";
    changelog = "https://github.com/eifinger/aioweenect/releases/tag/v${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
