{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jsonschema,
  licomp,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "licomp-hermione";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "hesa";
    repo = "licomp-hermione";
    tag = finalAttrs.version;
    hash = "sha256-TIfi7E+BBChOz/EXRJxjFRYavVRPfnSkBHTaiY87k/Y=";
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
    "licomp_hermione"
  ];

  meta = {
    description = "Implementation of Licomp using the Hermine license resource";
    homepage = "https://github.com/hesa/licomp-hermione";
    changelog = "https://github.com/hesa/licomp-hermione/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      bsd0
      gpl3Plus
      odbl
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
