{
  lib,
  fetchFromGitHub,
  # pipeline-train
  accelerate,
  # api
  aiohttp,
  # ann
  annoy,
  # pipeline-data
  beautifulsoup4,
  bitsandbytes,
  buildPythonPackage,
  # workflow
  # apache-libcloud (unpackaged)
  croniter,
  # database
  duckdb,
  # dependencies
  faiss-cpu,
  fastapi,
  fastapi-mcp,
  # cloud
  # apache-libcloud, (unpackaged)
  fasteners,
  # vectors
  fasttext,
  # llama-cpp-python, (unpackaged)
  # pipeline-text
  gliner,
  hnswlib,
  httpx,
  huggingface-hub,
  # pipeline-image
  imagehash,
  # pipeline-llm
  litellm,
  # optional-dependencies
  # agent
  mcpadapt,
  # tests
  msgpack,
  # graph
  # grand-cypher (unpackaged)
  # grand-graph (unpackaged)
  networkx,
  nltk,
  numpy,
  # model
  onnx,
  onnxmltools,
  onnxruntime,
  openpyxl,
  pandas,
  peft,
  pgvector,
  pillow,
  pytestCheckHook,
  python-multipart,
  pyyaml,
  regex,
  requests,
  # console
  rich,
  # pymagnitude-lite, (unpackaged)
  scikit-learn,
  scipy,
  sentence-transformers,
  sentencepiece,
  # build-system
  setuptools,
  skl2onnx,
  skops,
  smolagents,
  # pipeline-audio
  # model2vec,
  sounddevice,
  soundfile,
  sqlalchemy,
  sqlite-vec-c,
  staticvectors,
  tika,
  timm,
  torch,
  transformers,
  ttstokenizer,
  uvicorn,
  webrtcvad,
  xmltodict,
}:
let
  version = "9.10.0";
  agent = [
    mcpadapt
    smolagents
  ];
  ann = [
    annoy
    hnswlib
    pgvector
    sqlalchemy
    sqlite-vec-c
  ];
  api = [
    aiohttp
    fastapi
    fastapi-mcp
    httpx
    pillow
    python-multipart
    uvicorn
  ];
  cloud = [
    # apache-libcloud
    fasteners
  ];
  console = [ rich ];
  database = [
    duckdb
    pillow
    sqlalchemy
  ];
  graph = [
    # grand-cypher
    # grand-graph
    networkx
    sqlalchemy
  ];
  model = [
    onnx
    onnxruntime
  ];
  pipeline-audio = [
    onnx
    onnxruntime
    scipy
    sounddevice
    soundfile
    ttstokenizer
    webrtcvad
  ];
  pipeline-data = [
    beautifulsoup4
    nltk
    pandas
    tika
  ];
  pipeline-image = [
    imagehash
    pillow
    timm
  ];
  pipeline-llm = [
    litellm
    # llama-cpp-python
  ];
  pipeline-text = [
    gliner
    sentencepiece
    staticvectors
  ];
  pipeline-train = [
    accelerate
    bitsandbytes
    onnx
    onnxmltools
    onnxruntime
    peft
    skl2onnx
  ];
  pipeline =
    pipeline-audio
    ++ pipeline-data
    ++ pipeline-image
    ++ pipeline-llm
    ++ pipeline-text
    ++ pipeline-train;
  scoring = [ sqlalchemy ];
  vectors = [
    fasttext
    litellm
    # llama-cpp-python
    # model2vec
    # pymagnitude-lite
    scikit-learn
    sentence-transformers
    skops
  ];
  workflow = [
    # apache-libcloud
    croniter
    openpyxl
    pandas
    pillow
    requests
    xmltodict
  ];
  similarity = ann ++ vectors;
  all =
    agent
    ++ api
    ++ ann
    ++ console
    ++ database
    ++ graph
    ++ model
    ++ pipeline
    ++ scoring
    ++ similarity
    ++ workflow;

  optional-dependencies = {
    inherit
      agent
      ann
      api
      cloud
      console
      database
      graph
      model
      pipeline-audio
      pipeline-data
      pipeline-image
      pipeline-llm
      pipeline-text
      pipeline-train
      pipeline
      scoring
      similarity
      workflow
      all
      ;
  };

  src = fetchFromGitHub {
    owner = "neuml";
    repo = "txtai";
    tag = "v${version}";
    hash = "sha256-J+JIsaK43LXPoVrrw7Eh/zVMJ1b6WAsTdghE/jLjRX0=";
  };
in
buildPythonPackage {
  inherit version src;
  pname = "txtai";

  nativeCheckInputs = [
    httpx
    msgpack
    pytestCheckHook
    python-multipart
    timm
    sqlalchemy
  ]
  ++ optional-dependencies.agent
  ++ optional-dependencies.ann
  ++ optional-dependencies.api
  ++ optional-dependencies.similarity;

  # The Python imports check runs huggingface-hub which needs a writable directory.
  #  `pythonImportsCheck` runs in the installPhase (before checkPhase).
  preInstall = ''
    export HF_HOME=$(mktemp -d)
  '';

  build-system = [ setuptools ];

  dependencies = [
    faiss-cpu
    huggingface-hub
    msgpack
    numpy
    pyyaml
    regex
    torch
    transformers
  ];

  disabledTests = [
    # Hardcoded paths
    "testInvalidTar"
    "testInvalidZip"
    # Downloads from Huggingface
    "TestAgent"
    "TestCloud"
    "TestConsole"
    "TestEmbeddings"
    "TestGraph"
    "TestWorkflow"
    "testPipeline"
    "testVectors"
    # Not finding sqlite-vec despite being supplied
    "testSQLite"
    "testSQLiteCustom"
  ];

  enabledTestPaths = [
    "test/python/*"
  ];

  optional-dependencies = optional-dependencies;
  pyproject = true;
  pythonImportsCheck = [ "txtai" ];

  meta = {
    description = "Semantic search and workflows powered by language models";
    homepage = "https://github.com/neuml/txtai";
    changelog = "https://github.com/neuml/txtai/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
