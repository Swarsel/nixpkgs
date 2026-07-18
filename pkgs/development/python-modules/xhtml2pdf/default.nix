{
  lib,
  fetchFromGitHub,
  arabic-reshaper,
  buildPythonPackage,
  html5lib,
  pillow,
  pyhanko,
  pyhanko-certvalidator,
  pypdf,
  pytestCheckHook,
  python-bidi,
  reportlab,
  setuptools,
  svglib,
}:

buildPythonPackage rec {
  pname = "xhtml2pdf";
  version = "0.2.17";

  src = fetchFromGitHub {
    owner = "xhtml2pdf";
    repo = "xhtml2pdf";
    tag = "v${version}";
    hash = "sha256-qp0JVp5efIrI98YT0rwFAMSEW+0aIhedfYGND4V7Mto=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    arabic-reshaper
    html5lib
    pillow
    pyhanko
    pyhanko-certvalidator
    pypdf
    python-bidi
    reportlab
    svglib
  ];

  disabledTests = [
    # Tests requires network access
    "test_document_cannot_identify_image"
    "test_document_with_broken_image"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "xhtml2pdf"
    "xhtml2pdf.pisa"
  ];

  pythonRelaxDeps = [
    "reportlab"
  ];

  meta = {
    description = "PDF generator using HTML and CSS";
    homepage = "https://github.com/xhtml2pdf/xhtml2pdf";
    changelog = "https://github.com/xhtml2pdf/xhtml2pdf/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "xhtml2pdf";
  };
}
