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
  pname = "licomp-proprietary";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "hesa";
    repo = "licomp-proprietary";
    tag = finalAttrs.version;
    hash = "sha256-elEy/BOcuvo29ciRRSNQABWoBrOhRPDCNoaypuvWsx0=";
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
    "licomp_proprietary"
  ];

  meta = {
    description = "Implementation of Licomp for linking a Propriettary licensed module";
    homepage = "https://github.com/hesa/licomp-proprietary";
    changelog = "https://github.com/hesa/licomp-proprietary/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      cc-by-40
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
