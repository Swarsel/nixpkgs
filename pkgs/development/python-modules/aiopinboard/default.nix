{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  arrow,
  buildPythonPackage,
  certifi,
  frozenlist,
  poetry-core,
  pytest-aiohttp,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiopinboard";
  version = "2024.01.0";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "aiopinboard";
    tag = version;
    hash = "sha256-/N9r17e0ZvPmcqW/XtRyAENKCGRzWqeOSKPpWHHYomg=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    aiohttp
    arrow
    certifi
    frozenlist
    yarl
  ];

  nativeCheckInputs = [
    aresponses
    pytest-aiohttp
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiopinboard" ];

  meta = {
    description = "Library to interact with the Pinboard API";
    homepage = "https://github.com/bachya/aiopinboard";
    changelog = "https://github.com/bachya/aiopinboard/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
