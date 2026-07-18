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
  pname = "licomp-dwheeler";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "hesa";
    repo = "licomp-dwheeler";
    tag = finalAttrs.version;
    hash = "sha256-p6BSedKqauJCVpkr18UN6oNLwI2NknfJx8FHBIbi3I4=";
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
    "licomp_dwheeler"
  ];

  meta = {
    description = "Implementation of Licomp using David Wheeler's graph";
    homepage = "https://github.com/hesa/licomp-dwheeler";
    changelog = "https://github.com/hesa/licomp-dwheeler/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      cc-by-sa-30
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
