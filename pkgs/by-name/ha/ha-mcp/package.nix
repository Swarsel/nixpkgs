{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ha-mcp";
  version = "7.8.0";

  src = fetchFromGitHub {
    owner = "homeassistant-ai";
    repo = "ha-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+HhtHeSQlK1jd/4/x1d54Etvrs8e+pQkIGvJV39ZZBw=";
  };

  # Tests require a running Home Assistant instance
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies =
    with python3Packages;
    [
      cryptography
      fastmcp
      httpx
      pydantic
      pydantic-monty
      python-dotenv
      truststore
      websockets
    ]
    ++ httpx.optional-dependencies.socks;

  pyproject = true;
  pythonImportsCheck = [ "ha_mcp" ];
  pythonRelaxDeps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--use-github-releases"
      "--version-regex=^v([0-9]+\\.[0-9]+\\.[0-9]+)$"
    ];
  };

  meta = {
    description = "MCP server for controlling Home Assistant via natural language";
    homepage = "https://github.com/homeassistant-ai/ha-mcp";
    changelog = "https://github.com/homeassistant-ai/ha-mcp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
    mainProgram = "ha-mcp";
  };
})
