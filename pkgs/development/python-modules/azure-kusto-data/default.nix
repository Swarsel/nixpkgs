{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  # tests
  # aio:
  aiohttp,
  # tests
  aioresponses,
  asgiref,
  # dependencies
  azure-core,
  azure-identity,
  buildPythonPackage,
  ijson,
  msal,
  # pandas:
  pandas,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  python-dateutil,
  requests,
  # build-system
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-kusto-data";
  version = "6.0.4";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-kusto-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iggsVxLmDbP6+oSPaIiujPLsZAWwm5VLZSl+HYm0DIQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.9,<0.9.0" uv_build
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __structuredAttrs = true;
  build-system = [ uv-build ];

  dependencies = [
    azure-core
    azure-identity
    ijson
    msal
    python-dateutil
    requests
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/aio/test_async_token_providers.py"
    "tests/test_token_providers.py"
    "tests/test_e2e_data.py"

    # AssertionError: assert <class 'pandas.Timestamp'> is <class 'pandas.api.typing.NaTType'>
    "tests/test_helpers.py"
  ];

  disabledTests = [
    # AssertionError: Attributes of DataFrame.iloc[:, 1] (column name="rowguid") are different
    "test_sanity_data_frame"
  ];

  optional-dependencies = {
    aio = [
      aiohttp
      asgiref
    ];

    pandas = [ pandas ];
  };

  pyproject = true;
  pythonImportsCheck = [ "azure.kusto.data" ];

  pythonRelaxDeps = [
    "ijson"
  ];

  sourceRoot = "${finalAttrs.src.name}/azure-kusto-data";

  meta = {
    description = "Kusto Data Client";
    homepage = "https://github.com/Azure/azure-kusto-python/tree/master/azure-kusto-data";
    changelog = "https://github.com/Azure/azure-kusto-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
