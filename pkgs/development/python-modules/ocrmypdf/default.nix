{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecation,
  fpdf2,
  ghostscript_headless,
  hatch-vcs,
  hatchling,
  hypothesis,
  img2pdf,
  installShellFiles,
  jbig2enc,
  packaging,
  pdfminer-six,
  pikepdf,
  pillow,
  pillow-heif,
  pluggy,
  pngquant,
  pydantic,
  pypdfium2,
  pytest-xdist,
  pytestCheckHook,
  replaceVars,
  reportlab,
  rich,
  tesseract,
  uharfbuzz,
  unpaper,
}:

buildPythonPackage rec {
  pname = "ocrmypdf";
  version = "17.8.0";

  src = fetchFromGitHub {
    owner = "ocrmypdf";
    repo = "OCRmyPDF";
    tag = "v${version}";
    hash = "sha256-E6SheIepSXQPxTCf6/vWeGpUs0x7VO+h86JhtSxK6e0=";

    # The content of .git_archival.txt is substituted upon tarball creation,
    # which creates indeterminism if master no longer points to the tag.
    # See https://github.com/ocrmypdf/OCRmyPDF/issues/841
    postFetch = ''
      rm "$out/.git_archival.txt"
    '';
  };

  patches = [
    ./use-pillow-heif.patch
    (replaceVars ./paths.patch {
      gs = lib.getExe ghostscript_headless;
      jbig2 = lib.getExe jbig2enc;
      pngquant = lib.getExe pngquant;
      tesseract = lib.getExe tesseract;
      unpaper = lib.getExe unpaper;
    })
  ];

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = [
    hypothesis
    pytest-xdist
    pytestCheckHook
    reportlab
  ];

  postInstall = ''
    installShellCompletion --cmd ocrmypdf \
      --bash misc/completion/ocrmypdf.bash \
      --fish misc/completion/ocrmypdf.fish
  '';

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    deprecation
    fpdf2
    img2pdf
    packaging
    pdfminer-six
    pillow-heif
    pikepdf
    pillow
    pluggy
    pydantic
    pypdfium2
    rich
    uharfbuzz
  ];

  pyproject = true;
  pythonImportsCheck = [ "ocrmypdf" ];

  meta = {
    description = "Adds an OCR text layer to scanned PDF files, allowing them to be searched";
    homepage = "https://github.com/ocrmypdf/OCRmyPDF";
    changelog = "https://github.com/ocrmypdf/OCRmyPDF/blob/${src.tag}/docs/releasenotes/version17.md";

    license = with lib.licenses; [
      mpl20
      mit
    ];

    maintainers = with lib.maintainers; [
      dotlambda
    ];

    mainProgram = "ocrmypdf";
  };
}
