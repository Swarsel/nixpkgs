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
  pname = "licomp-oslc-handbook";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "hesa";
    repo = "licomp-oslc-handbook";
    tag = finalAttrs.version;
    hash = "sha256-cE3X7oT5Xg1W9lAMLJCYE6qRqrrXpVGLfBp18ynUYLE=";

    postFetch = ''
      # conflicts with `licenses` on Darwin, thus producing a different source
      # hash.
      mv $out/LICENSES $out/LICENSES_
    '';
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
    "licomp_oslc_handbook"
  ];

  meta = {
    description = "Licomp implementaiton of OSLC-handbook";
    homepage = "https://github.com/hesa/licomp-oslc-handbook";
    changelog = "https://github.com/hesa/licomp-oslc-handbook/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      cc-by-40
      cc-by-sa-40
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    # TODO: remove when this is resolved:
    # https://github.com/hesa/licomp-oslc-handbook/issues/4
    badPlatforms = lib.platforms.darwin;
    teams = with lib.teams; [ ngi ];
  };
})
