{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  mashumaro,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "open-meteo";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "frenck";
    repo = "python-open-meteo";
    rev = "v${version}";
    hash = "sha256-J106XeSglyqrFfP1ckbnDwfE7IikaNiBQ+m14PE2SBc=";
  };

  postPatch = ''
    # Upstream doesn't set a version for the pyproject.toml
    substituteInPlace pyproject.toml \
      --replace-fail "0.0.0" "${version}"
  '';

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    aiohttp
    mashumaro
    orjson
  ];

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  disabledTests = [
    # aiohttp api breakage
    "test_timeout"
  ];

  pyproject = true;
  pythonImportsCheck = [ "open_meteo" ];

  meta = {
    description = "Python client for the Open-Meteo API";
    homepage = "https://github.com/frenck/python-open-meteo";
    changelog = "https://github.com/frenck/python-open-meteo/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
