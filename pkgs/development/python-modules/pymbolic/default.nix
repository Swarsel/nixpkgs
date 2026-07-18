{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  constantdict,
  # build-system
  hatchling,
  # optional-dependencies
  matchpy,
  numpy,
  # tests
  pytestCheckHook,
  pytools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymbolic";
  version = "2025.1";

  src = fetchFromGitHub {
    owner = "inducer";
    repo = "pymbolic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cn2EdhMn5qjK854AF5AY4Hv4M5Ib6gPRJk+kQvsFWRk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ hatchling ];

  dependencies = [
    constantdict
    pytools
    typing-extensions
  ];

  optional-dependencies = {
    matchpy = [ matchpy ];
    numpy = [ numpy ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pymbolic" ];

  meta = {
    description = "Package for symbolic computation";
    homepage = "https://documen.tician.de/pymbolic/";
    changelog = "https://github.com/inducer/pymbolic/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
