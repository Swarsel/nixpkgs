{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  duckdb,
  elastic-transport,
  elasticsearch,
  fastavro,
  httpx,
  lz4,
  maxminddb,
  msgpack,
  pytest7CheckHook,
  pytz,
  setuptools,
  setuptools-scm,
  structlog,
  tqdm,
  zstandard,
}:

buildPythonPackage rec {
  pname = "flow-record";
  version = "3.21";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "flow.record";
    tag = version;
    hash = "sha256-hJZCWF81pMeHOZGc6zTA046hV1J0PNQGMlPD3mgyrRI=";
  };

  nativeCheckInputs = [
    elastic-transport
    pytest7CheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ msgpack ];

  disabledTestPaths = [
    # Input not available
    "tests/adapter/test_xlsx.py"
    # Requires rdump
    "tests/tools/test_rdump.py"
  ];

  disabledTests = [ "test_rdump_fieldtype_path_json" ];

  optional-dependencies = {
    avro = [ fastavro ] ++ fastavro.optional-dependencies.snappy;

    compression = [
      lz4
      zstandard
    ];

    duckdb = [
      duckdb
      pytz
    ];

    elastic = [ elasticsearch ];

    # xlsx = [ openpyxl ]; # Not available
    full = [
      structlog
      tqdm
    ]
    ++ optional-dependencies.compression;

    geoip = [ maxminddb ];
    splunk = [ httpx ];
  };

  pyproject = true;
  pythonImportsCheck = [ "flow.record" ];

  meta = {
    description = "Library for defining and creating structured data";
    homepage = "https://github.com/fox-it/flow.record";
    changelog = "https://github.com/fox-it/flow.record/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
