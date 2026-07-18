{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  awesomeversion,
  buildPythonPackage,
  mashumaro,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  rich,
  syrupy,
  textual,
  textual-plotext,
  typer,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "fumis";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "frenck";
    repo = "python-fumis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yh1gxQ8iqHIE/pavzjYUXdaHnnHD0Ae6Yd/Elc/ZNmY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "0.0.0" "${finalAttrs.version}"
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    awesomeversion
    mashumaro
    orjson
    yarl
  ];

  optional-dependencies = {
    cli = [
      rich
      textual
      textual-plotext
      typer
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fumis" ];

  meta = {
    description = "Asynchronous Python client for the Fumis WiRCU API";
    homepage = "https://github.com/frenck/python-fumis";
    changelog = "https://github.com/frenck/python-fumis/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
