{
  lib,
  fetchFromGitHub,
  aiohttp,
  anyio,
  buildPythonPackage,
  # optional dependencies
  datasets,
  # tests
  dirty-equals,
  distro,
  hatch-fancy-pypi-readme,
  # build-system
  hatchling,
  # dependencies
  httpx,
  httpx-aiohttp,
  numpy,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  respx,
  sniffio,
  tiktoken,
  time-machine,
  # tinker -- not packaged yet
  torch,
  transformers,
  typing-extensions,
  wandb,
}:

buildPythonPackage (finalAttrs: {
  pname = "fireworks-ai";
  version = "1.2.0-alpha.71";

  src = fetchFromGitHub {
    owner = "fw-ai-external";
    repo = "python-sdk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N5JjcYa3dRh1JTRjOIDpC8wykYzdj1rrMcU49UvWF7w=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==1.26.3" "hatchling>=1.26.3"
  '';

  strictDeps = true;

  nativeCheckInputs = [
    dirty-equals
    pytest-asyncio
    pytestCheckHook
    respx
    time-machine
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __structuredAttrs = true;

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    aiohttp
    anyio
    distro
    httpx
    httpx-aiohttp
    pydantic
    sniffio
    typing-extensions
  ];

  optional-dependencies = {
    training = [
      datasets
      numpy
      tiktoken
      torch
      transformers
      wandb
    ]
    ++ finalAttrs.passthru.optional-dependencies.training-sdk;

    training-sdk = [
      # tinker is not available in nixpkgs
      requests
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "fireworks"
  ];

  pythonRelaxDeps = [ "pydantic" ];

  meta = {
    description = "Client library for Fireworks.ai";
    homepage = "https://github.com/fw-ai-external/python-sdk";
    changelog = "https://github.com/fw-ai-external/python-sdk/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
