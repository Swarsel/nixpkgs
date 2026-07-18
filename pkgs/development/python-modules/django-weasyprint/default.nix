{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pytestCheckHook,
  setuptools,
  weasyprint,
}:

buildPythonPackage rec {
  pname = "django-weasyprint";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "fdemmer";
    repo = "django-weasyprint";
    tag = "v${version}";
    hash = "sha256-EwTEBIqAZGmtSXkSLZgNPCKA98IrymsUEaCHc1uQ2XE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    django
    weasyprint
  ];

  disabledTests = [
    # Fails with weasyprint >= 68 (tries to open /static/css/print.css in test env)
    "test_get_pdf_download_and_options"
  ];

  pyproject = true;
  pythonImportsCheck = [ "django_weasyprint" ];

  meta = {
    description = "Django class-based view generating PDF resposes using WeasyPrint";
    homepage = "https://github.com/fdemmer/django-weasyprint";
    changelog = "https://github.com/fdemmer/django-weasyprint/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hoh ];
  };
}
