{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jsonschema,
  # dependencies
  licomp,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "licomp-reclicense";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "hesa";
    repo = "licomp-reclicense";
    tag = finalAttrs.version;
    hash = "sha256-dCUsSZ70iKNCk8QcTtQ6Kn8BdyqK2E3Arkfx4aHmhmM=";
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
    licomp
  ];

  pyproject = true;

  pythonImportsCheck = [
    "licomp_reclicense"
  ];

  meta = {
    description = "Implementation of Licomp using the Recliense matrix";
    homepage = "https://github.com/hesa/licomp-reclicense";
    changelog = "https://github.com/hesa/licomp-reclicense/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      gpl3Plus
      mulan-psl2
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
