{
  lib,
  fetchFromGitHub,
  aiohttp,
  # dependencies (incl. optional)
  anyio,
  buildPythonPackage,
  dirty-equals,
  distro,
  # build-system
  hatch-fancy-pypi-readme,
  hatchling,
  httpx,
  httpx-aiohttp,
  importlib-metadata,
  mypy,
  nox,
  pydantic,
  # tests
  pyright,
  pytest,
  pytest-asyncio,
  pytest-xdist,
  respx,
  rich,
  ruff,
  sniffio,
  time-machine,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "perplexityai";
  version = "0.39.0";

  src = fetchFromGitHub {
    owner = "perplexityai";
    repo = "perplexity-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2uBWvur6R7i1Y8oT2MTac1j+f/UMEmdbaKowDbrc0pA=";
  };

  # Can't use relaxPythonDeps as this is a version lock in the build system
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"hatchling==1.26.3"' '"hatchling"'
  '';

  nativeCheckInputs = [
    pyright
    mypy
    respx
    pytest
    pytest-asyncio
    ruff
    time-machine
    nox
    dirty-equals
    importlib-metadata
    rich
    pytest-xdist
  ]
  ++ finalAttrs.passthru.optional-dependencies.aiohttp;

  __structuredAttrs = true;

  build-system = [
    hatch-fancy-pypi-readme
    hatchling
  ];

  dependencies = [
    anyio
    distro
    httpx
    pydantic
    sniffio
    typing-extensions
  ];

  optional-dependencies = {
    aiohttp = [
      aiohttp
      httpx-aiohttp
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "perplexity"
  ];

  meta = {
    description = "API for Perplexity AI";
    homepage = "https://github.com/perplexityai/perplexity-py";
    changelog = "https://github.com/perplexityai/perplexity-py/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
