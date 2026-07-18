{
  lib,
  fetchFromGitHub,
  authlib,
  buildPythonPackage,
  click,
  dparse,
  filelock,
  git,
  hatchling,
  httpx,
  jinja2,
  marshmallow,
  nltk,
  packaging,
  pydantic,
  pytestCheckHook,
  ruamel-yaml,
  safety-schemas,
  tenacity,
  tomli,
  tomlkit,
  truststore,
  typer,
  typing-extensions,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "safety";
  version = "3.8.1";

  src = fetchFromGitHub {
    owner = "pyupio";
    repo = "safety";
    tag = finalAttrs.version;
    hash = "sha256-xKZ8uhwuM6eu1NTppPFTBkxSjrguTw9GuIvPhPaTIAI=";
  };

  patches = [
    ./disable-telemetry.patch
  ];

  nativeCheckInputs = [
    git
    pytestCheckHook
    tomli
    writableTmpDirAsHomeHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    click
    packaging
    dparse
    ruamel-yaml
    jinja2
    marshmallow
    nltk
    authlib
    typer
    pydantic
    safety-schemas
    typing-extensions
    filelock
    httpx
    tenacity
    tomlkit
    truststore
  ];

  disabledTestPaths = [
    # Failed to initialize SafetyPlatformClient: [Errno -3] Temporary failure in name resolution
    "tests/firewall/test_command.py"
    "tests/test_cli.py"
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "safety-schemas"
  ];

  meta = {
    description = "Checks installed dependencies for known vulnerabilities";
    homepage = "https://github.com/pyupio/safety";
    changelog = "https://github.com/pyupio/safety/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      thomasdesr
      dotlambda
    ];

    mainProgram = "safety";
  };
})
