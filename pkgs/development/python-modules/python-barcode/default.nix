{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-barcode";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "WhyNotHugo";
    repo = "python-barcode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-a/w2JxFBm/jqIRnqIB7ZtkdiLnBNjbR0V5SNuau/YxY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ]
  ++ finalAttrs.passthru.optional-dependencies.images;

  build-system = [
    setuptools
    setuptools-scm
  ];

  optional-dependencies = {
    images = [ pillow ];
  };

  pyproject = true;
  pythonImportsCheck = [ "barcode" ];

  meta = {
    description = "Create standard barcodes with Python";
    homepage = "https://github.com/WhyNotHugo/python-barcode";
    changelog = "https://github.com/WhyNotHugo/python-barcode/blob/${finalAttrs.src.tag}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "python-barcode";
  };
})
