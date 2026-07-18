{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  awesomeversion,
  backoff,
  buildPythonPackage,
  cachetools,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "python-technove";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "Moustachauve";
    repo = "pytechnove";
    tag = "v${version}";
    hash = "sha256-TAB70EVrjxpl+vm3ncg45l2duaIXHjn7YKOURkS6k0k=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    awesomeversion
    backoff
    cachetools
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "technove" ];

  meta = {
    description = "Python library to interact with TechnoVE local device API";
    homepage = "https://github.com/Moustachauve/pytechnove";
    changelog = "https://github.com/Moustachauve/pytechnove/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
