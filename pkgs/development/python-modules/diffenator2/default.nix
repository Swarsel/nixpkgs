{
  lib,
  fetchFromGitHub,
  blackrenderer,
  buildPythonPackage,
  fonttools,
  freetype-py,
  gflanguages,
  glyphsets,
  jinja2,
  ninja,
  numpy,
  pillow,
  poetry-core,
  poetry-dynamic-versioning,
  protobuf,
  pyahocorasick,
  pytestCheckHook,
  python-bidi,
  selenium,
  tqdm,
  uharfbuzz,
  unicodedata2,
  youseedee,
}:

buildPythonPackage (finalAttrs: {
  pname = "diffenator2";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "diffenator2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7c9/D3uiHysvB2XCjlgm5ll71efLDgcQARXyKeGt5D0=";
  };

  env.PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = [
    blackrenderer
    fonttools
    freetype-py
    gflanguages
    glyphsets
    jinja2
    ninja
    pillow
    protobuf
    pyahocorasick
    python-bidi
    selenium
    tqdm
    uharfbuzz
    unicodedata2
    youseedee
    numpy
  ];

  disabledTestPaths = [
    # Want the files downloaded by the tests above
    "tests/test_functional.py"
    "tests/test_html.py"
    "tests/test_matcher.py"
    "tests/test_font.py"
  ];

  disabledTests = [
    # requires internet
    "test_download_google_fonts_family_to_file"
    "test_download_google_fonts_family_to_bytes"
    "test_download_google_fonts_family_not_existing"
    "test_download_latest_github_release"
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "protobuf"
    "python-bidi"
    "youseedee"
    "unicodedata2"
  ];

  meta = {
    description = "Font comparison tool that will not stop until your fonts are exhaustively compared";
    homepage = "https://github.com/googlefonts/diffenator2";
    changelog = "https://github.com/googlefonts/diffenator2/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    mainProgram = "diffenator2";
  };
})
