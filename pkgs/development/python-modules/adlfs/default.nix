{
  lib,
  fetchFromGitHub,
  aiohttp,
  azure-core,
  azure-datalake-store,
  azure-identity,
  azure-storage-blob,
  buildPythonPackage,
  fsspec,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "adlfs";
  version = "2026.5.0";

  src = fetchFromGitHub {
    owner = "fsspec";
    repo = "adlfs";
    tag = finalAttrs.version;
    hash = "sha256-HscDY/DZZ9/a3NHmE8pSd3alLCJQDG6Fr2l2+DfU/os=";
  };

  # Tests require a running Docker instance
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    azure-core
    azure-datalake-store
    azure-identity
    azure-storage-blob
    fsspec
  ];

  pyproject = true;
  pythonImportsCheck = [ "adlfs" ];
  pythonRelaxDeps = [ "azure-datalake-store" ];

  meta = {
    description = "Filesystem interface to Azure-Datalake Gen1 and Gen2 Storage";
    homepage = "https://github.com/fsspec/adlfs";
    changelog = "https://github.com/fsspec/adlfs/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
