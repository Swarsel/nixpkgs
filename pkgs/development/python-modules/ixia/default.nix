{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "ixia";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "trag1c";
    repo = "ixia";
    tag = finalAttrs.version;
    hash = "sha256-8STtLL63V+XnDqDNZOx7X9mkjUu176SSyQOL55LXFz0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "ixia" ];

  meta = {
    description = "Connecting secrets' security with random's versatility";
    homepage = "https://trag1c.github.io/ixia";
    changelog = "https://github.com/trag1c/ixia/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
