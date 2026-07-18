{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fire,
  fonttools,
  numpy,
  opencv-python-headless,
  pip,
  pymupdf,
  pytestCheckHook,
  python-docx,
  setuptools,
  tkinter,
}:
let
  version = "0.5.13";
in
buildPythonPackage {
  inherit version;
  pname = "pdf2docx";

  src = fetchFromGitHub {
    owner = "ArtifexSoftware";
    repo = "pdf2docx";
    tag = "v${version}";
    hash = "sha256-GZ7aUTSGSly21lMiUOXc6Y8h9WY2zQQxF5M11PwTtCA=";
  };

  preBuild = "echo '${version}' > version.txt";
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    pip
    setuptools
  ];

  dependencies = [
    pymupdf
    fire
    fonttools
    numpy
    opencv-python-headless
    python-docx
  ];

  # Test fails due to "RuntimeError: cannot find builtin font with name 'Arial'":
  disabledTests = [ "test_unnamed_fonts" ];

  enabledTestPaths = [
    "./test/test.py::TestConversion"
  ];

  pyproject = true;

  pytestFlags = [
    "-v"
  ];

  meta = {
    description = "Convert PDF to DOCX";
    homepage = "https://github.com/ArtifexSoftware/pdf2docx";
    changelog = "https://github.com/ArtifexSoftware/pdf2docx/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "pdf2docx";
  };
}
