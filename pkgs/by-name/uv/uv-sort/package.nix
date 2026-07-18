{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "uv-sort";
  version = "0.7.0";

  # Build from GitHub does not work. Use fetchPypi instead of fetchFromGitHub.
  # See https://github.com/NixOS/nixpkgs/pull/388382#issuecomment-2708857805
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-vOD4QPrI5EoofLpMkRPvwz1pONDpg5hDcK0pdPX4pFA=";
    pname = "uv_sort";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
  ];

  build-system = with python3Packages; [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = with python3Packages; [
    packaging
    tomlkit
    typer
  ];

  pyproject = true;

  meta = {
    description = "Sort uv's dependencies alphabetically";
    homepage = "https://github.com/ninoseki/uv-sort";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aaronjheng ];
    mainProgram = "uv-sort";
  };
})
