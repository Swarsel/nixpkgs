{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  mashumaro,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "essent-dynamic-pricing";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "jaapp";
    repo = "py-essent-dynamic-pricing";
    tag = "v${version}";
    hash = "sha256-98dh9XNXIVDI0w0/RqEGnDbDpQQoaZz/TvMIl6t3c3o=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "essent_dynamic_pricing" ];

  meta = {
    description = "Async client for Essent dynamic energy prices";
    homepage = "https://github.com/jaapp/py-essent-dynamic-pricing";
    changelog = "https://github.com/jaapp/py-essent-dynamic-pricing/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
