{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
  syrupy,
}:

buildPythonPackage rec {
  pname = "odp-amsterdam";
  version = "6.1.2";

  src = fetchFromGitHub {
    owner = "klaasnicolaas";
    repo = "python-odp-amsterdam";
    tag = "v${version}";
    hash = "sha256-vamWelyEcwvYI5I9wmKk8kKc7j0OMer/BKgC0pbN4g0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"0.0.0"' '"${version}"'
    sed -i '/addopts/d' pyproject.toml
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
    syrupy
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    aiohttp
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "odp_amsterdam" ];
  pythonRelaxDeps = [ "pytz" ];

  meta = {
    description = "Python client for getting garage occupancy in Amsterdam";
    homepage = "https://github.com/klaasnicolaas/python-odp-amsterdam";
    changelog = "https://github.com/klaasnicolaas/python-odp-amsterdam/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
