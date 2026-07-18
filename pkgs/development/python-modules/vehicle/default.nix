{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  rich,
  syrupy,
  typer,
  yarl,
}:

buildPythonPackage rec {
  pname = "vehicle";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "frenck";
    repo = "python-vehicle";
    tag = "v${version}";
    hash = "sha256-gmLBm3ru525cayhdRJ0Ccwsq+juZRQAAjCQQq7g0m+0=";
  };

  postPatch = ''
    # Upstream doesn't set a version for the pyproject.toml
    substituteInPlace pyproject.toml \
      --replace "0.0.0" "${version}"
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
    yarl
  ];

  optional-dependencies = {
    cli = [
      rich
      typer
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "vehicle" ];

  meta = {
    description = "Python client providing RDW vehicle information";
    homepage = "https://github.com/frenck/python-vehicle";
    changelog = "https://github.com/frenck/python-vehicle/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "vehicle";
  };
}
