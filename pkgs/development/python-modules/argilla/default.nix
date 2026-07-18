{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiosqlite,
  alembic,
  asyncpg,
  backoff,
  brotli-asgi,
  buildPythonPackage,
  cleanlab,
  datasets,
  elasticsearch8,
  evaluate,
  factory-boy,
  faiss,
  fastapi,
  flyingsquid,
  greenlet,
  httpx,
  huggingface-hub,
  luqum,
  monotonic,
  numpy,
  openai,
  opensearch-py,
  packaging,
  pandas,
  passlib,
  pdm-backend,
  peft,
  pgmpy,
  pillow,
  plotly,
  prodict,
  psutil,
  psycopg2,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  python-jose,
  python-multipart,
  pyyaml,
  rich,
  schedule,
  scikit-learn,
  sentence-transformers,
  seqeval,
  smart-open,
  snorkel,
  spacy,
  spacy-transformers,
  sqlalchemy,
  standardwebhooks,
  tqdm,
  transformers,
  typer,
  uvicorn,
  wrapt,
  # , flair
  # , setfit
  # , spacy-huggingface-hub
  # , span_marker
  # , trl
}:

buildPythonPackage rec {
  pname = "argilla";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "argilla-io";
    repo = "argilla";
    tag = "v${version}";
    hash = "sha256-8j7/Gtn4FnAZA3oIV7dLxKwNtigqB7AweHtQ/kzLwm4=";
  };

  # Still quite a bit of optional dependencies missing
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    pytest-asyncio
    factory-boy
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [ pdm-backend ];

  dependencies = [
    httpx
    datasets
    packaging
    pandas
    pydantic
    wrapt
    numpy
    tqdm
    pillow
    huggingface-hub
    monotonic
    rich
    typer
    standardwebhooks
  ];

  disabledTestPaths = [ "tests/server/datasets/test_dao.py" ];

  optional-dependencies = {
    integrations = [
      cleanlab
      evaluate
      faiss
      flyingsquid
      openai
      peft
      pgmpy
      plotly
      pyyaml
      sentence-transformers
      seqeval
      snorkel
      spacy
      spacy-transformers
      transformers
      # flair
      # setfit
      # span_marker
      # trl
      # spacy-huggingface-hub
    ]
    ++ transformers.optional-dependencies.torch;

    listeners = [
      schedule
      prodict
    ];

    postgresql = [
      asyncpg
      psycopg2
    ];

    server = [
      aiofiles
      aiosqlite
      alembic
      backoff
      brotli-asgi
      elasticsearch8
      fastapi
      greenlet
      luqum
      opensearch-py
      passlib
      psutil
      python-jose
      python-multipart
      pyyaml
      scikit-learn
      smart-open
      sqlalchemy
      uvicorn
    ]
    ++ elasticsearch8.optional-dependencies.async
    ++ uvicorn.optional-dependencies.standard
    ++ python-jose.optional-dependencies.cryptography
    ++ passlib.optional-dependencies.bcrypt;
  };

  pyproject = true;

  pythonRelaxDeps = [
    "httpx"
    "numpy"
    "rich"
    "typer"
    "wrapt"
  ];

  sourceRoot = "${src.name}/${pname}";

  meta = {
    description = "Open-source data curation platform for LLMs";
    homepage = "https://github.com/argilla-io/argilla";
    changelog = "https://github.com/argilla-io/argilla/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "argilla";
  };
}
