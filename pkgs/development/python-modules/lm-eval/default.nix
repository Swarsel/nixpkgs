{
  lib,
  fetchFromGitHub,
  # dependencies
  accelerate,
  # optional-dependencies
  aiohttp,
  buildPythonPackage,
  datasets,
  dill,
  evaluate,
  immutabledict,
  jinja2,
  jsonlines,
  langdetect,
  librosa,
  more-itertools,
  nltk,
  numpy,
  optimum,
  pandas,
  peft,
  pymorphy2,
  pytablewriter,
  # tests
  pytestCheckHook,
  requests,
  rouge-score,
  sacrebleu,
  scikit-learn,
  sentencepiece,
  # build-system
  setuptools,
  soundfile,
  sqlitedict,
  statsmodels,
  tenacity,
  tiktoken,
  torch,
  tqdm,
  transformers,
  typing-extensions,
  vllm,
  wandb,
  word2number,
  writableTmpDirAsHomeHook,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "lm-eval";
  version = "0.4.11";

  src = fetchFromGitHub {
    owner = "EleutherAI";
    repo = "lm-evaluation-harness";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+zhZ+I+gzoF7g0xYvlPbZFcFy2PuFOgNTFLvbmdE1R0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    sentencepiece
    writableTmpDirAsHomeHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.api
  ++ finalAttrs.passthru.optional-dependencies.hf;

  build-system = [
    setuptools
  ];

  dependencies = [
    datasets
    dill
    evaluate
    jinja2
    jsonlines
    more-itertools
    pytablewriter
    rouge-score
    sacrebleu
    scikit-learn
    sqlitedict
    typing-extensions
    word2number
    zstandard
  ];

  disabledTestPaths = [
    # attempts to download models
    "tests/models/test_bos_handling.py"
    "tests/models/test_huggingface.py"
    "tests/test_evaluator.py"
    "tests/test_include_path.py"
    "tests/test_prompt.py"
    "tests/test_task_manager.py"
    "tests/test_tasks.py"
    "tests/test_unitxt_tasks.py"

    # optimum-intel is not available
    "tests/models/test_openvino.py"

    # zeno-client is not packaged
    "tests/scripts/test_zeno_visualize.py"
  ];

  disabledTests = [
    "test_deepsparse" # deepsparse is not available

    # download models from the internet
    "test_get_batched_requests_with_no_ssl"
    "test_model_tokenized_call_usage"
  ];

  optional-dependencies = {
    api = [
      aiohttp
      requests
      tenacity
      tiktoken
      tqdm
    ];

    audiolm_qwen = [
      librosa
      soundfile
    ];

    discrim_eval = [ statsmodels ];

    hf = [
      accelerate
      peft
      torch
      transformers
    ];

    ifeval = [
      immutabledict
      langdetect
      nltk
    ];

    libra = [
      pymorphy2
    ];

    optimum = [ optimum ] ++ optimum.optional-dependencies.openvino;
    sentencepiece = [ sentencepiece ];
    vllm = [ vllm ];

    wandb = [
      numpy
      pandas
      wandb
    ];
    # Still missing dependencies for the following optional dependency groups:
    # - acpbench
    # - deepsparse
    # - gptq
    # - gptqmodel
    # - ibm_watsonx_ai
    # - ipex
    # - japanese_leaderboard
    # - longbench
    # - math
    # - multilingual
    # - ruler
    # - sparsify
    # - tasks
    # - unitxt
    # - zeno
  };

  pyproject = true;
  pythonImportsCheck = [ "lm_eval" ];
  pythonRelaxDeps = [ "datasets" ];

  meta = {
    description = "Framework for few-shot evaluation of language models";
    homepage = "https://github.com/EleutherAI/lm-evaluation-harness";
    changelog = "https://github.com/EleutherAI/lm-evaluation-harness/releases/tag/${finalAttrs.src.tag}";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers.booxter ];
  };
})
