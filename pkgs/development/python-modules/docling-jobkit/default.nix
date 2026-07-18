{
  lib,
  stdenv,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  # dependencies
  docling,
  fastparquet,
  # build-system
  hatchling,
  httpx,
  msgpack,
  pandas,
  poetry-core,
  pyarrow,
  pydantic-settings,
  pytest-asyncio,
  # tests
  pytestCheckHook,
  # optional dependencies
  ray,
  rq,
  typer,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "docling-jobkit";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "docling-project";
    repo = "docling-jobkit";
    tag = "v${version}";
    hash = "sha256-9DzQY/XMmx/8XP1bMYZYl+Bp7AVcYfuv3MtO6lvQ/24=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    writableTmpDirAsHomeHook
  ]
  ++ optional-dependencies.rq;

  build-system = [
    hatchling
    poetry-core
  ];

  dependencies = [
    docling
    pydantic-settings
    typer
    boto3
    pandas
    fastparquet
    pyarrow
    httpx
  ];

  disabledTests = [
    # requires network access
    "test_chunk_file"
    "test_convert_file"
    "test_convert_warmup"
    "test_convert_url"
    "test_replicated_convert"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Flaky due to comparison with magic object
    # https://github.com/docling-project/docling-jobkit/issues/45
    "test_options_validator"
  ];

  optional-dependencies = {
    ray = [ ray ];

    rq = [
      rq
      msgpack
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "docling"
    "docling_jobkit"
  ];

  pythonRelaxDeps = [
    "boto3"
    "pandas"
    "pyarrow"
  ];

  meta = {
    description = "Running a distributed job processing documents with Docling";
    homepage = "https://github.com/docling-project/docling-jobkit";
    changelog = "https://github.com/docling-project/docling-jobkit/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ codgician ];
  };
}
