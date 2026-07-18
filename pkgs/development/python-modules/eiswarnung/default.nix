{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pytz,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "eiswarnung";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "klaasnicolaas";
    repo = "python-eiswarnung";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/61qrRfD7/gaEcvFot34HYXOVLWwTDi/fvcgHDTv9u0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"0.0.0"' '"${finalAttrs.version}"'
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    pytz
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "eiswarnung" ];
  pythonRelaxDeps = [ "pytz" ];

  meta = {
    description = "Module for getting Eiswarning API forecasts";
    homepage = "https://github.com/klaasnicolaas/python-eiswarnung";
    changelog = "https://github.com/klaasnicolaas/python-eiswarnung/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
