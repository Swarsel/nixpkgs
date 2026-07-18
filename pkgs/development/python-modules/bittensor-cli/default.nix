{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-substrate-interface,
  backoff,
  bittensor-drand,
  bittensor-wallet,
  buildPythonPackage,
  cyscale,
  flit-core,
  gitpython,
  jinja2,
  netaddr,
  numpy,
  packaging,
  plotille,
  plotly,
  pycryptodome,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  rich,
  typer,
}:

buildPythonPackage (finalAttrs: {
  pname = "bittensor-cli";
  version = "9.23.1";

  src = fetchFromGitHub {
    owner = "latent-to";
    repo = "btcli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rwPYuDfRi3L1BvNN+MoqJlJjyp/vyK7/p6iyB7RJ9Wk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  __structuredAttrs = true;
  build-system = [ flit-core ];

  dependencies = [
    aiohttp
    async-substrate-interface
    backoff
    bittensor-drand
    bittensor-wallet
    cyscale
    gitpython
    jinja2
    netaddr
    numpy
    packaging
    plotille
    plotly
    pycryptodome
    pyyaml
    rich
    typer
  ];

  # e2e tests require a running subtensor node
  disabledTestPaths = [ "tests/e2e_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "bittensor_cli" ];

  pythonRelaxDeps = [
    "rich"
    "typer"
  ];

  meta = {
    description = "Bittensor command line tool";
    homepage = "https://github.com/latent-to/btcli";
    changelog = "https://github.com/latent-to/btcli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kilyanni ];
    mainProgram = "btcli";
  };
})
