{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiosqlite,
  buildPythonPackage,
  cbor2,
  dbutils,
  msgpack,
  pymysql,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "persist-queue";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "peter-wangxu";
    repo = "persist-queue";
    tag = "v${version}";
    hash = "sha256-8LtXTpwAk71sjxvZudwk+4P4ohlWC0zagr5F8PTkTwk=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  optional-dependencies = {
    async = [
      aiofiles
      aiosqlite
    ];

    extra = [
      cbor2
      dbutils
      msgpack
      pymysql
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "persistqueue" ];

  meta = {
    description = "Thread-safe disk based persistent queue in Python";
    homepage = "https://github.com/peter-wangxu/persist-queue";
    changelog = "https://github.com/peter-wangxu/persist-queue/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ huantian ];
  };
}
