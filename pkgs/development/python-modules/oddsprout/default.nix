{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dahlia,
  hatchling,
  ixia,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "oddsprout";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "trag1c";
    repo = "oddsprout";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RfAU3/Je3aC8JjQ51DqRCSAIfW2tQmQPP6G0/bfa1ZE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    dahlia
    ixia
  ];

  pyproject = true;
  pythonImportsCheck = [ "oddsprout" ];

  meta = {
    description = "Generate random JSON with no schemas involved";
    homepage = "https://trag1c.github.io/oddsprout";
    changelog = "https://github.com/trag1c/oddsprout/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      itepastra
      sigmanificient
    ];

    mainProgram = "oddsprout";
  };
})
