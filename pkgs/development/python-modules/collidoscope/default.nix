{
  lib,
  fetchFromGitHub,
  babelfont,
  buildPythonPackage,
  fonttools,
  kurbopy,
  pytestCheckHook,
  setuptools,
  skia-pathops,
  tqdm,
  uharfbuzz,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "collidoscope";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "collidoscope";
    tag = "v${version}";
    hash = "sha256-1tKbv+i2gbUFJa94xSEj5BrEpZ0+ULgglkYvGMP4NXw=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    babelfont
    kurbopy
    fonttools
    skia-pathops
    tqdm
    uharfbuzz
  ];

  pyproject = true;

  unittestFlagsArray = [
    "-s"
    "test"
    "-v"
  ];

  meta = {
    description = "Python library to detect glyph collisions in fonts";
    homepage = "https://github.com/googlefonts/collidoscope";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}
