{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  mashumaro,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-freezer,
  pytestCheckHook,
  syrupy,
  typer,
  yarl,
}:

buildPythonPackage rec {
  pname = "easyenergy";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "klaasnicolaas";
    repo = "python-easyenergy";
    tag = "v${version}";
    hash = "sha256-GzsTAm5D0DVQ7OHfsCwn7Jdv1K1rEhz3KGuERRlTEmI=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace '"0.0.0"' '"${version}"'
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytest-freezer
    pytestCheckHook
    syrupy
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    mashumaro
    yarl
  ];

  disabledTests = [
    # Tests require network access
    "test_json_request"
    "test_internal_session"
    "test_electricity_model_usage"
    "test_electricity_model_return"
    "test_electricity_none_data"
    "test_no_electricity_data"
    "test_gas_morning_model"
    "test_gas_model"
    "test_gas_none_data"
    "test_no_gas_data"
    "test_electricity_midnight"
  ];

  optional-dependencies = {
    cli = [ typer ];
  };

  pyproject = true;
  pythonImportsCheck = [ "easyenergy" ];

  pythonRelaxDeps = [
    "aiohttp"
    "mashumaro"
  ];

  meta = {
    description = "Module for getting energy/gas prices from easyEnergy";
    homepage = "https://github.com/klaasnicolaas/python-easyenergy";
    changelog = "https://github.com/klaasnicolaas/python-easyenergy/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "easyenergy";
  };
}
