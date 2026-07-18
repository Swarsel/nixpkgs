{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  adlfs,
  # optional-dependencies
  av,
  boto3,
  buildPythonPackage,
  cargo,
  clickhouse-connect,
  cloudpickle,
  dask,
  databricks-sdk,
  datasets,
  deltalake,
  duckdb,
  fetchgit,
  # dependencies
  fsspec,
  gcsfs,
  google-cloud-bigtable,
  google-genai,
  httpx,
  huggingface-hub,
  hypothesis,
  jax,
  jaxtyping,
  librosa,
  lxml,
  memray,
  moto,
  mypy-boto3-glue,
  nasm,
  numpy,
  openai,
  opencv-python,
  packaging,
  pandas,
  pgvector,
  pillow,
  pkg-config,
  psycopg,
  pyarrow,
  pydantic,
  pyiceberg,
  pymysql,
  pyodbc,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  pythonOlder,
  ray,
  reportlab,
  requests,
  rustPlatform,
  rustc,
  s3fs,
  sentence-transformers,
  soundfile,
  sqlalchemy,
  sqlglot,
  tenacity,
  tiktoken,
  torch,
  torchvision,
  tqdm,
  transformers,
  typing-extensions,
  writableTmpDirAsHomeHook,
  xxhash,
}:

buildPythonPackage (finalAttrs: {
  pname = "daft";
  version = "0.7.14";

  src = fetchFromGitHub {
    owner = "Eventual-Inc";
    repo = "Daft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qw1NB+RvXOFMHZvqpD5CSLWSUUKmtfWr0EyBgRMv2lA=";
  };

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'version = "0.3.0-dev0"' 'version = "${finalAttrs.version}"'

    # ArrayChunks::into_remainder() returns IntoIter<_, N> on current stable
    # rustc but Option<IntoIter<_, N>> on the nightly upstream pins.
    substituteInPlace src/daft-minhash/src/lib.rs \
      --replace-fail 'chunks.into_remainder()' 'Some(chunks.into_remainder())'

    # `hash_map_macro` was renamed/removed in newer rustc; the gate is declared
    # but never used in the crate.
    substituteInPlace src/daft-distributed/src/lib.rs \
      --replace-fail '#![feature(hash_map_macro)]' ""
  '';

  nativeBuildInputs = [
    cargo
    pkg-config
    rustc
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ]
  ++ lib.optional stdenv.hostPlatform.isx86_64 nasm;

  env = {
    # avoid building frontend npm
    CI = "1";
    DAFT_DASHBOARD_SKIP_BUILD = "1";
    DAFT_RUNNER = "native";
    NIX_CFLAGS_COMPILE = "-Wno-error";
    # daft-minhash uses #![feature(portable_simd)] which requires nightly
    RUSTC_BOOTSTRAP = "1";
  };

  nativeCheckInputs = [
    adlfs
    av
    boto3
    clickhouse-connect
    cloudpickle
    dask
    databricks-sdk
    datasets
    deltalake
    duckdb
    gcsfs
    google-cloud-bigtable
    google-genai
    huggingface-hub
    hypothesis
    jax
    jaxtyping
    librosa
    lxml
    memray
    moto
    numpy
    opencv-python
    openai
    pandas
    pgvector
    pillow
    pydantic
    pyiceberg
    pymysql
    pyodbc
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    ray
    reportlab
    s3fs
    sentence-transformers
    soundfile
    sqlalchemy
    sqlglot
    tenacity
    tiktoken
    torch
    torchvision
    transformers
    writableTmpDirAsHomeHook
    xxhash
  ];

  preCheck = ''
    rm -rf daft
  '';

  __structuredAttrs = true;

  cargoDeps =
    (rustPlatform.importCargoLock.override {
      fetchgit =
        args:
        if (args.url or null) == "https://github.com/Eventual-Inc/azure-sdk-for-rust" then
          fetchgit (
            args
            // {
              postFetch = (args.postFetch or "") + ''
                substituteInPlace $out/services/Cargo.toml \
                  --replace-fail '"mgmt/batch",' '"mgmt/batch", "svc/blobstorage",'
              '';
            }
          )
        else
          fetchgit args;
    })
      {
        lockFile = ./Cargo.lock;

        outputHashes = {
          "azure_core-0.21.0" = "sha256-I8kzIkguRa3REwii0xsFFpNhE90/QX5msXwE6rrzDlY=";
        };
      };

  dependencies = [
    fsspec
    packaging
    pyarrow
    tqdm

    # daft/series.py imports `Self` from typing_extensions unconditionally,
    # even though upstream pyproject.toml marks it python_version < '3.11'.
    typing-extensions
  ];

  disabled = pythonOlder "3.10";

  disabledTestPaths = [
    "tests/integration"
    "tests/benchmarks"
    "tests/microbenchmarks"

    # require packages: daft-lance, mcap, turbopuffer, unitycatalog, connectorx
    "tests/io/lancedb"
    "tests/io/mcap"
    "tests/io/test_turbopuffer_write.py"
    "tests/io/test_roundtrip_embeddings.py"
    "tests/io/test_sql.py"
    "tests/checkpoint/test_native_runner_gate.py"
    "tests/dataframe/test_explain.py"
    "tests/dataframe/test_limit_offset.py"
    "tests/catalog/test_catalog.py"
    "tests/catalog/test_unity_auth.py"
    "tests/catalog/test_unity_oauth2.py"

    # broken upstream
    "tests/io/test_s3_credentials_refresh.py"

    # require network access
    "tests/ai"
    "tests/sql/test_uri_exprs.py"
    "tests/recordbatch/test_tokenize.py"

    # spawns subprocess Python without daft on path
    "tests/test_context.py"

    # ray runtime OOMs
    "tests/ray"
  ];

  disabledTests = [
    # writes via relative paths fail in the sandbox
    "test_append_and_overwrite_local_relative_path"

    # require network access
    "test_to_tempfile_remote"

    # broken upstream
    "test_table_concat_schema_mismatch"
  ];

  dontUseCmakeConfigure = true;

  optional-dependencies = {
    audio = [
      librosa
      soundfile
    ];

    aws = [
      boto3
      mypy-boto3-glue
    ];

    azure = [ ];
    clickhouse = [ clickhouse-connect ];
    deltalake = [ deltalake ];
    gcp = [ ];

    google = [
      google-genai
      numpy
      pillow
    ];

    gravitino = [ requests ];
    hudi = [ pyarrow ];

    huggingface = [
      datasets
      huggingface-hub
    ];

    iceberg = [ pyiceberg ];
    numpy = [ numpy ];

    openai = [
      numpy
      openai
      pillow
    ];

    pandas = [ pandas ];

    postgres = [
      pgvector
      psycopg
      sqlglot
    ];

    ray = [ ray ];

    sql = [
      sqlalchemy
      sqlglot
    ];

    transformers = [
      pillow
      sentence-transformers
      torch
      torchvision
      transformers
    ];

    unity = [
      deltalake
      httpx
    ];

    video = [ av ];
    viz = [ ];
  };

  pyproject = true;
  pythonImportsCheck = [ "daft" ];
  pythonRelaxDeps = [ "fsspec" ];

  meta = {
    description = "Distributed dataframes for multimodal data";
    homepage = "https://github.com/Eventual-Inc/Daft";
    changelog = "https://github.com/Eventual-Inc/Daft/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ derdennisop ];
    platforms = lib.platforms.unix;
    mainProgram = "daft";
  };
})
