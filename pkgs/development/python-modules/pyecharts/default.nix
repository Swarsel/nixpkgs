{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  numpy,
  pandas,
  pillow,
  prettytable,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  setuptools,
  setuptools-scm,
  simplejson,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyecharts";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "pyecharts";
    repo = "pyecharts";
    tag = "v${finalAttrs.version}";
    hash = "sha256-49ALxObzUuw3N81ZTgtQYtqTA1CTu7Qz9E6OkkJyEnc=";
  };

  nativeCheckInputs = [
    numpy
    pandas
    pytestCheckHook
    requests
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    jinja2
    prettytable
    simplejson
  ];

  disabledTests = [
    # Tests require network access
    "test_render_embed_js"
    "test_display_javascript_v2"
    "test_lines3d_base"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # pyecharts.exceptions.WordCloudMaskImageException
    "test_wordcloud_encode_image_to_base64_os_error"
  ];

  optional-dependencies = {
    images = [ pillow ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyecharts" ];

  meta = {
    description = "Python Echarts Plotting Library";
    homepage = "https://github.com/pyecharts/pyecharts";
    changelog = "https://github.com/pyecharts/pyecharts/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
