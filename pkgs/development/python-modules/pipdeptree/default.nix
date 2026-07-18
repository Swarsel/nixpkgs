{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  graphviz,
  hatch-vcs,
  hatchling,
  packaging,
  pip-requirements-parser,
  pytest-mock,
  pytest-subprocess,
  pytestCheckHook,
  rich,
  virtualenv,
}:

buildPythonPackage (finalAttrs: {
  pname = "pipdeptree";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "tox-dev";
    repo = "pipdeptree";
    tag = finalAttrs.version;
    hash = "sha256-EDpKJBDb3CkTMfiLyYMakbm5riIHsf+49yM99uQDPT8=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytest-subprocess
    pytestCheckHook
    virtualenv
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [ packaging ];

  disabledTests = [
    # Don't run console tests
    "test_console"
  ];

  optional-dependencies = {
    graphviz = [ graphviz ];

    index = [
      # nab-index # Unstable + not packaged yet
      # nab-python # Same
      pip-requirements-parser
    ];

    rich = [ rich ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pipdeptree" ];

  meta = {
    description = "Command line utility to show dependency tree of packages";
    homepage = "https://github.com/tox-dev/pipdeptree";
    changelog = "https://github.com/tox-dev/pipdeptree/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      charlesbaynham
      mdaniels5757
    ];

    mainProgram = "pipdeptree";
  };
})
