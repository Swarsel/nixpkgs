{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  hatchling,
  mashumaro,
  orjson,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "pyfirefly";
  version = "0.1.16";

  src = fetchFromGitHub {
    owner = "erwindouna";
    repo = "pyfirefly";
    tag = "v${version}";
    hash = "sha256-RrVjXhV42DBvmTcZMowmHXN5K4nZfKPT/CDbvf1tOAQ=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyfirefly" ];

  meta = {
    description = "Asynchronous Python client for the Firefly III API";
    homepage = "https://github.com/erwindouna/pyfirefly";
    changelog = "https://github.com/erwindouna/pyfirefly/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
