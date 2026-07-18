{
  lib,
  buildPythonPackage,
  fetchFromGitea,
  jsonschema,
  # tests
  pytestCheckHook,
  # dependencies
  pyyaml,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "licomp";
  version = "0.5.22";

  src = fetchFromGitea {
    owner = "software-compliance-org";
    repo = "licomp";
    tag = finalAttrs.version;
    hash = "sha256-yZZfWinXdMmF/FQQ3+MwHRypK5Xz2EEMruJLCAtl/6Q=";
    domain = "codeberg.org";
  };

  nativeCheckInputs = [
    pytestCheckHook
    jsonschema
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pyyaml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "licomp"
  ];

  meta = {
    description = "License Compatibility - Generalised API for use in license compatibility";
    homepage = "https://codeberg.org/software-compliance-org/licomp";

    license = with lib.licenses; [
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
