{
  lib,
  fetchFromGitHub,
  aiorwlock,
  # , azure-ai-formrecognizer
  beautifulsoup4,
  black,
  boilerpy3,
  boto3,
  botocore,
  buildPythonPackage,
  canals,
  coverage,
  dulwich,
  elastic-transport,
  elasticsearch,
  events,
  faiss-cpu,
  hatchling,
  httpx,
  huggingface-hub,
  jinja2,
  jsonschema,
  langdetect,
  lazy-imports,
  markdown,
  # , jupytercontrib
  mkdocs,
  mlflow,
  more-itertools,
  mypy,
  networkx,
  nltk,
  onnxruntime,
  onnxruntime-tools,
  openai,
  openai-whisper,
  # , onnxruntime-gpu
  opensearch-py,
  pandas,
  pdf2image,
  pillow,
  # , faiss-gpu
  pinecone-client,
  platformdirs,
  posthog,
  pre-commit,
  prompthub-py,
  psutil,
  psycopg2,
  pydantic,
  # , pydoc-markdown
  pylint,
  pymupdf,
  pytesseract,
  pytest,
  pytest-asyncio,
  pytest-cov,
  python-docx,
  python-frontmatter,
  python-magic,
  # , pytest-custom-exit-code
  python-multipart,
  quantulum3,
  rank-bm25,
  rapidfuzz,
  ray,
  reno,
  requests,
  requests-cache,
  responses,
  scikit-learn,
  scipy,
  # , beir
  selenium,
  sentence-transformers,
  seqeval,
  sqlalchemy,
  sqlalchemy-utils,
  sseclient-py,
  tenacity,
  tika,
  tiktoken,
  toml,
  tox,
  tqdm,
  transformers,
  watchdog,
  weaviate-client,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "haystack-ai";
  version = "2.22.0";

  src = fetchFromGitHub {
    owner = "deepset-ai";
    repo = "haystack";
    tag = "v${version}";
    hash = "sha256-QqQTlyVUJU90lzMUe43Qd0WXXaxUi/53apvz/GlrsY0=";
  };

  nativeBuildInputs = [
    hatchling
    writableTmpDirAsHomeHook
  ];

  propagatedBuildInputs = [
    boilerpy3
    events
    httpx
    jsonschema
    lazy-imports
    more-itertools
    networkx
    pandas
    pillow
    platformdirs
    posthog
    prompthub-py
    pydantic
    quantulum3
    rank-bm25
    requests
    requests-cache
    scikit-learn
    sseclient-py
    tenacity
    tiktoken
    tqdm
    transformers
  ];

  # the setup for test is intensive, hopefully can be done at some point
  doCheck = false;

  optional-dependencies = {
    # all = [
    #   farm-haystack
    # ];
    # all-gpu = [
    #   farm-haystack
    # ];
    audio = [ openai-whisper ];

    aws = [
      boto3
      botocore
    ];

    # beir = [
    #   beir
    # ];
    colab = [ pillow ];
    crawler = [ selenium ];

    dev = [
      coverage
      dulwich
      # jupytercontrib
      mkdocs
      mypy
      pre-commit
      psutil
      # pydoc-markdown
      pylint
      pytest
      pytest-asyncio
      pytest-cov
      # pytest-custom-exit-code
      python-multipart
      reno
      responses
      toml
      tox
      watchdog
    ];

    elasticsearch7 = [
      elastic-transport
      elasticsearch
    ];

    elasticsearch8 = [
      elastic-transport
      elasticsearch
    ];

    file-conversion = [
      # azure-ai-formrecognizer
      beautifulsoup4
      markdown
      python-docx
      python-frontmatter
      python-magic
      # python-magic-bin
      tika
    ];

    formatting = [ black ];

    inference = [
      huggingface-hub
      sentence-transformers
      transformers
    ];

    metrics = [
      mlflow
      rapidfuzz
      scipy
      seqeval
    ];

    ocr = [
      pdf2image
      pytesseract
    ];

    only-faiss = [ faiss-cpu ];
    # only-faiss-gpu = [
    #   faiss-gpu
    # ];
    only-pinecone = [ pinecone-client ];

    onnx = [
      onnxruntime
      onnxruntime-tools
    ];

    # onnx-gpu = [
    #   onnxruntime-gpu
    #   onnxruntime-tools
    # ];
    opensearch = [ opensearch-py ];
    pdf = [ pymupdf ];

    preprocessing = [
      langdetect
      nltk
    ];

    preview = [
      canals
      jinja2
      lazy-imports
      openai
      pandas
      rank-bm25
      requests
      tenacity
      tqdm
    ];

    ray = [
      aiorwlock
      ray
    ];

    sql = [
      psycopg2
      sqlalchemy
      sqlalchemy-utils
    ];

    weaviate = [ weaviate-client ];
  };

  pyproject = true;
  pythonImportsCheck = [ "haystack" ];

  meta = {
    description = "LLM orchestration framework to build customizable, production-ready LLM applications";

    longDescription = ''
      LLM orchestration framework to build customizable, production-ready LLM applications. Connect components (models, vector DBs, file converters) to pipelines or agents that can interact with your data. With advanced retrieval methods, it's best suited for building RAG, question answering, semantic search or conversational agent chatbots
    '';

    homepage = "https://github.com/deepset-ai/haystack";
    changelog = "https://github.com/deepset-ai/haystack/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    # https://github.com/deepset-ai/haystack/issues/5304
    broken = lib.versionAtLeast pydantic.version "2";
  };
}
