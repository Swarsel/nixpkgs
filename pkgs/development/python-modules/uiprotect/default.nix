{
  lib,
  fetchFromGitHub,
  # dependencies
  aiofiles,
  aiohttp,
  # tests
  aiosqlite,
  aiozoneinfo,
  asttokens,
  av,
  buildPythonPackage,
  convertertools,
  dateparser,
  ffmpeg,
  orjson,
  packaging,
  pillow,
  platformdirs,
  # build-system
  poetry-core,
  propcache,
  pydantic,
  pydantic-extra-types,
  pyjwt,
  pytest-asyncio,
  pytest-benchmark,
  pytest-cov-stub,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  rich,
  typer,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "uiprotect";
  version = "15.4.3";

  src = fetchFromGitHub {
    owner = "uilibs";
    repo = "uiprotect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H5ymzsqdCcL9C4suW2Gk1Op7UmmwztqNrB1VeGIFUFE=";
  };

  nativeCheckInputs = [
    aiosqlite
    asttokens
    ffmpeg # Required for command ffprobe
    pytest-asyncio
    pytest-benchmark
    pytest-cov-stub
    pytest-timeout
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiofiles
    aiohttp
    aiozoneinfo
    av
    convertertools
    dateparser
    orjson
    packaging
    pillow
    platformdirs
    propcache
    pydantic
    pydantic-extra-types
    pyjwt
    rich
    typer
    yarl
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "uiprotect" ];

  pythonRelaxDeps = [
    "orjson"
    "packaging"
    "platformdirs"
    "propcache"
    "pydantic"
    "pyjwt"
    "rich"
    "typer"
  ];

  meta = {
    description = "Python API for UniFi Protect (Unofficial)";
    homepage = "https://github.com/uilibs/uiprotect";
    changelog = "https://github.com/uilibs/uiprotect/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
