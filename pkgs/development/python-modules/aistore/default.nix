{
  lib,
  # etl:
  aiofiles,
  # pytorch:
  alive-progress,
  # dependencies
  braceexpand,
  buildPythonPackage,
  cloudpickle,
  fastapi,
  fetchPypi,
  flask,
  gunicorn,
  # build-system
  hatchling,
  httpx,
  humanize,
  # mcp:
  mcp,
  msgspec,
  overrides,
  packaging,
  pydantic,
  python-dateutil,
  pyyaml,
  requests,
  tenacity,
  torch,
  torchdata,
  urllib3,
  uvicorn,
  webdataset,
  # optional-dependencies
  # botocore:
  wrapt,
  xxhash,
}:

buildPythonPackage (finalAttrs: {
  pname = "aistore";
  version = "1.25.0";

  # Tags on GitHub do not match
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-aslNCRSV7QKgvvDuUQPgcbUyUDdGP2kC4ryFu6IVYYE=";
  };

  # No tests in the Pypi archive
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    braceexpand
    cloudpickle
    humanize
    msgspec
    overrides
    packaging
    pydantic
    python-dateutil
    pyyaml
    requests
    tenacity
    urllib3
    xxhash
  ];

  optional-dependencies = {
    botocore = [
      wrapt
    ];

    etl = [
      aiofiles
      fastapi
      flask
      gunicorn
      httpx
      uvicorn
    ];

    mcp = [
      mcp
    ];

    pytorch = [
      alive-progress
      torch
      torchdata
      webdataset
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aistore" ];

  meta = {
    description = "Client-side APIs to access and utilize clusters, buckets, and objects on AIStore";
    homepage = "https://aistore.nvidia.com";
    changelog = "https://github.com/NVIDIA/aistore/blob/main/python/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    downloadPage = "https://github.com/NVIDIA/aistore/tree/main/python/aistore/sdk";
  };
})
