{
  lib,
  accelerate,
  buildPythonPackage,
  cohere,
  diskcache,
  fastapi,
  fetchPypi,
  google-auth,
  openai,
  pydantic,
  pyyaml,
  setuptools,
  setuptools-scm,
  tiktoken,
  transformers,
  typer,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "llmx";
  version = "0.0.21a0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OEo6wIaDTktzAsP0rOmhxjFSHygTR/EpcRI6AXsu+6M=";
  };

  # Tests of llmx try to access openai, google, etc.
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pydantic
    openai
    tiktoken
    diskcache
    cohere
    google-auth
    typer
    pyyaml
  ];

  optional-dependencies = {
    transformers = [
      accelerate
      transformers
    ]
    ++ transformers.optional-dependencies.torch;

    web = [
      fastapi
      uvicorn
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "llmx" ];

  meta = {
    description = "Library for LLM Text Generation";
    homepage = "https://github.com/victordibia/llmx";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "llmx";
  };
}
