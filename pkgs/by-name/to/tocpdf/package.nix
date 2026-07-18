{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tocpdf";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "kszenes";
    repo = "tocPDF";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RaNMhEgJ2pSL9BvK1d2Z8AsUPhARaRtEiCnt/2E2uNs=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    pdfplumber
    pypdf
    tika
    tqdm
  ];

  disabledTests = [
    # touches network
    "test_read_toc"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tocPDF" ];

  meta = {
    description = "Automatic CLI tool for generating outline of PDFs based on the table of contents";
    homepage = "https://github.com/kszenes/tocPDF";
    changelog = "https://github.com/kszenes/tocPDF/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dansbandit ];
    mainProgram = "tocPDF";
  };
})
