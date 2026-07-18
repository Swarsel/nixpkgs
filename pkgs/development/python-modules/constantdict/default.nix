{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "constantdict";
  version = "2025.3";

  src = fetchFromGitHub {
    owner = "matthiasdiener";
    repo = "constantdict";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jX6g9xBteZOc/7Ob5N8eUSCycb6JoE5i38T52zknOTI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
  ];

  # Assumes that unpickling a pickled dict in a different Python process will result in a different hash.
  # This doesn't seem to work in the Nix sandbox but works fine in a normal environment.
  disabledTests = [
    "test_pickle_hash"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "constantdict"
  ];

  meta = {
    description = "Immutable dictionary class for Python, implemented as a thin layer around Python's builtin dict class";
    homepage = "https://matthiasdiener.github.io/constantdict";
    changelog = "https://github.com/matthiasdiener/constantdict/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
    downloadPage = "https://github.com/matthiasdiener/constantdict";
  };
})
