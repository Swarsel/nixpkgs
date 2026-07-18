{
  lib,
  fetchFromGitHub,
  aiohttp,
  azure-kusto-data,
  azure-storage-blob,
  azure-storage-queue,
  buildPythonPackage,
  pandas,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  responses,
  tenacity,
  uv-build,
}:

buildPythonPackage rec {
  pname = "azure-kusto-ingest";
  version = "6.0.4";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-kusto-python";
    tag = "v${version}";
    hash = "sha256-iggsVxLmDbP6+oSPaIiujPLsZAWwm5VLZSl+HYm0DIQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.9,<0.9.0" uv-build
  '';

  nativeCheckInputs = [
    aiohttp
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    responses
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ uv-build ];

  dependencies = [
    azure-kusto-data
    azure-storage-blob
    azure-storage-queue
    tenacity
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/test_e2e_ingest.py"
  ];

  optional-dependencies = {
    pandas = [ pandas ];
  };

  pyproject = true;
  pythonImportsCheck = [ "azure.kusto.ingest" ];

  pythonRelaxDeps = [
    "azure-storage-blob"
    "azure-storage-queue"
  ];

  sourceRoot = "${src.name}/${pname}";

  meta = {
    description = "Module for Kusto Ingest";
    homepage = "https://github.com/Azure/azure-kusto-python/tree/master/azure-kusto-ingest";
    changelog = "https://github.com/Azure/azure-kusto-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
