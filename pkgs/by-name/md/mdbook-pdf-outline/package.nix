{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mdbook-pdf-outline";
  version = "0.1.6";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-GPTDlgYpfPtcq+rJCjxgexfViYiqHoVZ8iQkyWXNogw=";
    pname = "mdbook_pdf_outline";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
  ];

  propagatedBuildInputs = [
    python3Packages.lxml
    python3Packages.pypdf
  ];

  pyproject = true;

  meta = {
    homepage = "https://github.com/HollowMan6/mdbook-pdf";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ hollowman6 ];

  };
})
