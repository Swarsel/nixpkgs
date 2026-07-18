{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiointercept,
  aioresponses,
  buildPythonPackage,
  deepdiff,
  fastmcp,
  hatchling,
  pycognito,
  pyjwt,
  pytest-aiohttp,
  pytest-cov-stub,
  pytest-freezegun,
  pytest-timeout,
  pytestCheckHook,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "pylitterbot";
  version = "2025.6.1";

  src = fetchFromGitHub {
    owner = "natekspencer";
    repo = "pylitterbot";
    tag = finalAttrs.version;
    hash = "sha256-KKedO+NN/yeFYIGuiAJbch4SJ1QBsRfehVWx0y3SltQ=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-aiohttp
    pytest-cov-stub
    pytest-freezegun
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    aiointercept
    aiohttp
    deepdiff
    fastmcp
    pycognito
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylitterbot" ];

  meta = {
    description = "Modulefor controlling a Litter-Robot";
    homepage = "https://github.com/natekspencer/pylitterbot";
    changelog = "https://github.com/natekspencer/pylitterbot/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
