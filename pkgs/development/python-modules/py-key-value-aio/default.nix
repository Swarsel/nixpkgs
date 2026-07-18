{
  lib,
  stdenv,
  fetchFromGitHub,
  # dynamodb
  aioboto3,
  # filetree
  aiofile,
  aiohttp,
  # types-hvac,
  # memcached
  aiomcache,
  anyio,
  # dependencies
  beartype,
  # tests
  bson,
  buildPythonPackage,
  # optional-dependencies
  # memory
  cachetools,
  # wrappers-encryption
  cryptography,
  # keyring-linux
  dbus-python,
  dirty-equals,
  # disk
  diskcache,
  docker,
  # duckdb
  duckdb,
  # elasticsearch
  elasticsearch,
  # valkey
  # valkey-glide,
  # vault
  hvac,
  inline-snapshot,
  # keyring
  keyring,
  pathvalidate,
  py-key-value-shared,
  py-key-value-shared-test,
  # pydantic
  pydantic,
  # mongodb
  pymongo,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
  # redis
  redis,
  # rocksdb
  rocksdict,
  types-aiobotocore-dynamodb,
  # build-system
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-key-value-aio";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "strawgate";
    repo = "py-key-value";
    tag = finalAttrs.version;
    hash = "sha256-4ji+GzJTv1QnC5n/OaL9vR65j8BQmJsVGGnjjuulDiU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        "uv_build>=0.8.2,<0.9.0" \
        "uv_build"
  ''
  # Tests fail when using pytest-xdist ('Worker crashes')
  # https://github.com/strawgate/py-key-value/issues/266
  + ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        '"-n=auto",' \
        ""
    substituteInPlace pyproject.toml \
      --replace-fail \
        '"--dist=loadfile",' \
        ""
  '';

  nativeCheckInputs = [
    bson
    dirty-equals
    docker
    duckdb
    inline-snapshot
    py-key-value-shared-test
    pytest-asyncio
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.disk
  ++ finalAttrs.passthru.optional-dependencies.dynamodb
  ++ finalAttrs.passthru.optional-dependencies.elasticsearch
  ++ finalAttrs.passthru.optional-dependencies.filetree
  ++ finalAttrs.passthru.optional-dependencies.keyring
  ++ finalAttrs.passthru.optional-dependencies.memcached
  ++ finalAttrs.passthru.optional-dependencies.memory
  ++ finalAttrs.passthru.optional-dependencies.mongodb
  ++ finalAttrs.passthru.optional-dependencies.pydantic
  ++ finalAttrs.passthru.optional-dependencies.redis
  ++ finalAttrs.passthru.optional-dependencies.rocksdb
  ++ finalAttrs.passthru.optional-dependencies.wrappers-encryption;

  build-system = [
    uv-build
  ];

  dependencies = [
    beartype
    py-key-value-shared
  ];

  disabledTestPaths = [
    # ModuleNotFoundError: No module named 'bson.codec_options'
    "tests/stores/mongodb/test_mongodb.py"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # keyring.errors.PasswordSetError: Can't store password on keychain: (-61, 'Unknown Error')
    "tests/stores/keyring/test_keyring.py"

    # Worker crashes
    # https://github.com/strawgate/py-key-value/issues/266
    "tests/stores/rocksdb/test_rocksdb.py"
  ];

  optional-dependencies = {
    disk = [
      diskcache
      pathvalidate
    ];

    duckdb = [
      duckdb
      pytz
    ];

    dynamodb = [
      aioboto3
      types-aiobotocore-dynamodb
    ];

    elasticsearch = [
      elasticsearch
      aiohttp
    ];

    filetree = [
      aiofile
      anyio
    ];

    keyring = [
      keyring
    ];

    keyring-linux = [
      keyring
      dbus-python
    ];

    memcached = [
      aiomcache
    ];

    memory = [
      cachetools
    ];

    mongodb = [
      pymongo
    ];

    pydantic = [
      pydantic
    ];

    redis = [
      redis
    ];

    rocksdb = [
      rocksdict
    ];

    valkey = [
      # valkey-glide (unpackaged)
    ];

    vault = [
      hvac
      # types-hvac (unpackaged)
    ];

    wrappers-encryption = [
      cryptography
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "key_value.aio" ];
  sourceRoot = "${finalAttrs.src.name}/key-value/key-value-aio";

  meta = {
    description = "Async Key-Value";
    homepage = "https://github.com/strawgate/py-key-value/tree/main/key-value/key-value-aio";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
