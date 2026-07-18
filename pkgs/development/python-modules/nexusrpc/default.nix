{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  nix-update-script,
  pyright,
  pytest-asyncio,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "nexus-rpc";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "nexus-rpc";
    repo = "sdk-python";
    tag = version;
    hash = "sha256-il+zCyU0dOlqFHGedyeBKgwQlqx1FLNuriGIw3RV3Gs=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # Patch out uv and run tests directly
    substituteInPlace tests/test_type_errors.py \
      --replace-fail '["uv", "run", "pyright",' '["pyright",'
  '';

  nativeCheckInputs = [
    pyright
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "nexusrpc"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nexus Python SDK";
    homepage = "https://temporal.io/";
    changelog = "https://github.com/nexus-rpc/sdk-python/releases/tag/${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jpds
    ];
  };
}
