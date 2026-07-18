{
  lib,
  # dependencies
  anthropic,
  authlib,
  azure-identity,
  buildPythonPackage,
  cyclopts,
  exceptiongroup,
  fastmcp,
  google-genai,
  griffelib,
  # build-system
  hatchling,
  httpx,
  jsonref,
  jsonschema-path,
  mcp,
  openai,
  openapi-pydantic,
  opentelemetry-api,
  packaging,
  platformdirs,
  py-key-value-aio,
  pydantic,
  pydantic-monty,
  pydantic-settings,
  pydocket,
  pyjwt,
  pyperclip,
  python-dotenv,
  python-multipart,
  pyyaml,
  rich,
  typing-extensions,
  uncalled-for,
  uv-dynamic-versioning,
  uvicorn,
  watchfiles,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  inherit (fastmcp) version src;
  pname = "fastmcp-slim";
  # tests are done in fastmcp package
  doCheck = false;

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    platformdirs
    pydantic
    pydantic-settings
    python-dotenv
    rich
    typing-extensions
  ]
  ++ pydantic.optional-dependencies.email;

  optional-dependencies = {
    anthropic = [ anthropic ];

    apps = [
      # unpackaged prefab-ui
    ];

    azure = [
      azure-identity
      pyjwt
    ];

    client = [
      authlib
    ]
    ++ finalAttrs.passthru.optional-dependencies.mcp
    ++ py-key-value-aio.optional-dependencies.filetree
    ++ py-key-value-aio.optional-dependencies.keyring
    ++ py-key-value-aio.optional-dependencies.memory;

    code-mode = [ pydantic-monty ];

    gemini = [
      google-genai
      jsonref
    ];

    mcp = [
      exceptiongroup
      httpx
      mcp
      opentelemetry-api
    ];

    openai = [ openai ];

    server = [
      authlib
      cyclopts
      griffelib
      jsonref
      jsonschema-path
      openapi-pydantic
      packaging
      py-key-value-aio
      pyperclip
      python-multipart
      pyyaml
      uncalled-for
      uvicorn
      watchfiles
      websockets
    ]
    ++ finalAttrs.passthru.optional-dependencies.mcp
    ++ py-key-value-aio.optional-dependencies.filetree
    ++ py-key-value-aio.optional-dependencies.keyring
    ++ py-key-value-aio.optional-dependencies.memory;

    tasks = [
      pydocket
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fastmcp" ];
  sourceRoot = "${finalAttrs.src.name}/fastmcp_slim";

  meta = {
    description = "Dependency-slim FastMCP package";
    homepage = "https://github.com/PrefectHQ/fastmcp/tree/main/fastmcp_slim";
    changelog = "https://github.com/jlowin/fastmcp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
