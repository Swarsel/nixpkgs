{
  lib,
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "pdfposter";
  version = "0.9.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Y5gUrHI470vsORETxkpf3WH5YXgdIeTZvSb3v/UgD24=";
    pname = "pdfposter";
  };

  build-system = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [ pypdf ];
  pyproject = true;

  pythonImportsCheck = [
    "pdfposter"
    "pdfposter.cmd"
  ];

  meta = {
    description = "Split large pages of a PDF into smaller ones for poster printing";
    homepage = "https://pdfposter.readthedocs.io";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wamserma ];
    mainProgram = "pdfposter";
  };
}
