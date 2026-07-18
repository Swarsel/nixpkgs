{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-freezer,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "energyzero";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "klaasnicolaas";
    repo = "python-energyzero";
    tag = "v${version}";
    hash = "sha256-Tisng08X/jyNtT27qy1hH6qM6Nqho/X8bg1tFg1oIx8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"0.0.0"' '"${version}"'
  '';

  propagatedBuildInputs = [
    aiohttp
    yarl
  ];

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytest-freezer
    pytestCheckHook
    syrupy
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "energyzero" ];

  meta = {
    description = "Module for getting the dynamic prices from EnergyZero";
    homepage = "https://github.com/klaasnicolaas/python-energyzero";
    changelog = "https://github.com/klaasnicolaas/python-energyzero/releases/tag/v${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
