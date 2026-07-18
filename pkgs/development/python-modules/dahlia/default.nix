{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "dahlia";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "dahlia-lib";
    repo = "dahlia";
    tag = finalAttrs.version;
    hash = "sha256-489wI0SoC6EU9lC2ISYsLOJUC8g+kLA7UpOrDiBCBmo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "dahlia" ];

  meta = {
    description = "Simple text formatting package, inspired by the game Minecraft";
    homepage = "https://github.com/dahlia-lib/dahlia";
    changelog = "https://github.com/dahlia-lib/dahlia/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "dahlia";
  };
})
