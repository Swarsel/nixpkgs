{
  lib,
  fetchFromGitHub,
  a2a-sdk,
  aiohttp,
  anthropic,
  apscheduler,
  azure-identity,
  azure-keyvault-secrets,
  azure-storage-blob,
  azure-storage-file-datalake,
  backoff,
  boto3,
  buildPythonPackage,
  click,
  cryptography,
  fastapi,
  fastapi-sso,
  fastuuid,
  google-cloud-iam,
  google-cloud-kms,
  google-genai,
  grpcio,
  gunicorn,
  httpx,
  importlib-metadata,
  jinja2,
  jsonschema,
  langfuse,
  mcp,
  nix-update-script,
  nixosTests,
  openai,
  opentelemetry-api,
  opentelemetry-exporter-otlp,
  opentelemetry-sdk,
  orjson,
  polars,
  prisma,
  prometheus-client,
  pydantic,
  pyjwt,
  pynacl,
  pypdf,
  python-dotenv,
  python-multipart,
  pyyaml,
  resend,
  restrictedpython,
  rich,
  rq,
  sentry-sdk,
  soundfile,
  tiktoken,
  tokenizers,
  uv-build,
  uvicorn,
  uvloop,
  websockets,
}:

buildPythonPackage rec {
  pname = "litellm";
  version = "1.89.0";

  src = fetchFromGitHub {
    owner = "BerriAI";
    repo = "litellm";
    tag = "v${version}";
    hash = "sha256-tPw4cDqCQgyC8EoB5EPfui2gT+frjlSMOv95ntUXTWk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build==0.11.8" "uv_build"
  '';

  # access network
  doCheck = false;
  build-system = [ uv-build ];

  dependencies = [
    aiohttp
    click
    fastuuid
    httpx
    importlib-metadata
    jinja2
    jsonschema
    openai
    pydantic
    python-dotenv
    tiktoken
    tokenizers
  ];

  optional-dependencies = {
    extra_proxy = [
      a2a-sdk
      azure-identity
      azure-keyvault-secrets
      google-cloud-iam
      google-cloud-kms
      prisma
      # FIXME package redisvl
      resend
    ];

    proxy = [
      apscheduler
      azure-identity
      azure-storage-blob
      backoff
      boto3
      cryptography
      fastapi
      fastapi-sso
      gunicorn
      # FIXME package litellm-enterprise
      # FIXME package litellm-proxy-extras
      mcp
      orjson
      polars
      pyjwt
      pynacl
      python-multipart
      pyyaml
      restrictedpython
      rich
      rq
      soundfile
      uvloop
      uvicorn
      websockets
    ];

    proxy-runtime = [
      anthropic
      # FIXME package azure-ai-contentsafety
      azure-storage-file-datalake
      # FIXME package ddtrace
      # FIXME package detect-secrets
      # FIXME package google-cloud-aiplatform
      google-genai
      grpcio
      langfuse
      # FIXME package mangum
      opentelemetry-api
      opentelemetry-exporter-otlp
      opentelemetry-sdk
      # FIXME package llm-sandbox
      prometheus-client
      pypdf
      sentry-sdk
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "litellm" ];

  pythonRelaxDeps = [
    "aiohttp"
    "click"
    "importlib-metadata"
    "jsonschema"
    "openai"
    "pydantic"
    "python-dotenv"
  ];

  passthru = {
    tests = { inherit (nixosTests) litellm; };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "v([0-9]+\\.[0-9]+\\.[0-9]+)"
      ];
    };
  };

  meta = {
    description = "Use any LLM as a drop in replacement for gpt-3.5-turbo. Use Azure, OpenAI, Cohere, Anthropic, Ollama, VLLM, Sagemaker, HuggingFace, Replicate (100+ LLMs)";
    homepage = "https://github.com/BerriAI/litellm";
    changelog = "https://github.com/BerriAI/litellm/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "litellm";
  };
}
