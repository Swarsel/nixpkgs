{
  lib,
  fetchFromGitHub,
  attrs,
  binaryornot,
  buildPythonPackage,
  commoncode,
  pdfminer-six,
  plugincode,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  typecode-libmagic,
}:

buildPythonPackage (finalAttrs: {
  pname = "typecode";
  version = "30.2.0";

  src = fetchFromGitHub {
    owner = "aboutcode-org";
    repo = "typecode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+7Yu2t++4PaF8yT+kKgo5MP6lbr8CXkjo5/4KMrApZY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    attrs
    pdfminer-six
    commoncode
    plugincode
    binaryornot
    typecode-libmagic
  ];

  disabledTests = [
    "TestFileTypesDataDriven"

    # Many of the failures below are reported in:
    # https://github.com/aboutcode-org/typecode/issues/36

    # fails due to change in file (libmagic) 5.45
    "test_media_image_img"
  ];

  dontConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "typecode" ];

  meta = {
    description = "Comprehensive filetype and mimetype detection using libmagic and Pygments";
    homepage = "https://github.com/aboutcode-org/typecode";
    changelog = "https://github.com/aboutcode-org/typecode/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
