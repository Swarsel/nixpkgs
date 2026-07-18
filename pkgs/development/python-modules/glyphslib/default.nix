{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defcon,
  fonttools,
  openstep-plist,
  pytestCheckHook,
  setuptools-scm,
  skia-pathops,
  ufo2ft,
  ufolib2,
  ufonormalizer,
  unicodedata2,
  xmldiff,
}:

buildPythonPackage (finalAttrs: {
  pname = "glyphslib";
  version = "6.13.1";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "glyphsLib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MV6dEAk7toBzcXzCWpjnEoJwhdYPC609HpNWzCvVyGc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];

  dependencies = [
    fonttools
    openstep-plist
    ufolib2
    unicodedata2
    ufonormalizer
    xmldiff
    defcon
    ufo2ft
    skia-pathops
  ];

  disabledTestPaths = [
    "tests/builder/designspace_gen_test.py" # this test tries to use non-existent font "CoolFoundry Examplary Serif"
    "tests/builder/interpolation_test.py" # this test tries to use a font that previous test should made
  ];

  pyproject = true;
  pythonImportsCheck = [ "glyphsLib" ];

  meta = {
    description = "Bridge from Glyphs source files (.glyphs) to UFOs and Designspace files via defcon and designspaceLib";
    homepage = "https://github.com/googlefonts/glyphsLib";
    changelog = "https://github.com/googlefonts/glyphsLib/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
