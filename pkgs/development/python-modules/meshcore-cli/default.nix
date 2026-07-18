{
  lib,
  fetchFromGitHub,
  # dependencies
  bleak,
  buildPythonPackage,
  # build-system
  hatchling,
  meshcore,
  prompt-toolkit,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "meshcore-cli";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "meshcore-dev";
    repo = "meshcore-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wby97e9Xulk2pwNJ9mnvKxWlTsWmH4n3zlTtYi7WS6I=";
  };

  doCheck = false; # no tests
  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    meshcore
    bleak
    prompt-toolkit
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "meshcore_cli"
  ];

  meta = {
    description = "Command line interface to MeshCore node";
    homepage = "https://github.com/meshcore-dev/meshcore-cli";
    changelog = "https://github.com/meshcore-dev/meshcore-cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.haylin ];
    mainProgram = "meshcore-cli";
  };
})
