{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  fontmath,
  fonttools,
  glyphslib,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  skia-pathops,
  ttfautohint-py,
  ufo2ft,
  ufolib2,
}:

buildPythonPackage rec {
  pname = "fontmake";
  version = "3.12.1";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "fontmake";
    tag = "v${version}";
    hash = "sha256-dgforezrilmD2d6MFY3Z5X/82yPRfSW/I/OxXcZ+xJw=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.autohint;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fontmath
    fonttools
    glyphslib
    ufo2ft
    ufolib2
  ]
  ++ fonttools.optional-dependencies.ufo
  ++ fonttools.optional-dependencies.lxml
  ++ fonttools.optional-dependencies.unicode;

  optional-dependencies = {
    autohint = [ ttfautohint-py ];
    json = ufolib2.optional-dependencies.json;
    pathops = [ skia-pathops ];
    repacker = fonttools.optional-dependencies.repacker;
  };

  pyproject = true;
  pythonImportsCheck = [ "fontmake" ];

  meta = {
    description = "Compiles fonts from various sources (.glyphs, .ufo, designspace) into binaries formats (.otf, .ttf)";
    homepage = "https://github.com/googlefonts/fontmake";
    changelog = "https://github.com/googlefonts/fontmake/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
