{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  httpx,
  jinja2,
  nodeenv,
  pydantic,
  python-dotenv,
  setuptools,
  tomlkit,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "prisma";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "RobertCraigie";
    repo = "prisma-client-py";
    tag = "v${version}";
    hash = "sha256-F+Up1HHslralt3NvZZ/wT+CKvzKOjhEEuMEeT0L6NZM=";
  };

  # Building the client requires network access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    click
    httpx
    jinja2
    nodeenv
    pydantic
    python-dotenv
    tomlkit
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "prisma" ];

  meta = {
    description = "Auto-generated and fully type-safe database client for prisma";
    homepage = "https://github.com/RobertCraigie/prisma-client-py";
    changelog = "https://github.com/RobertCraigie/prisma-client-py/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
