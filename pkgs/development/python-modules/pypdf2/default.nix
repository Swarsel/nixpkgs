{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
}:

buildPythonPackage rec {
  pname = "pypdf2";
  version = "3.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-p0QI9pumJx9xuTUu9O0D3FOjGqQE0ptdMfU7/s/uFEA=";
    pname = "PyPDF2";
  };

  nativeBuildInputs = [ flit-core ];
  # no test
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "PyPDF2" ];

  meta = {
    description = "Pure-Python library built as a PDF toolkit";
    homepage = "https://pypdf2.readthedocs.io/";
    changelog = "https://github.com/py-pdf/PyPDF2/raw/${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;

    knownVulnerabilities = [
      "CVE-2026-27024"
      "CVE-2026-27025"
      "CVE-2026-27628"
      "CVE-2026-27888"
      "CVE-2026-28351"
      "CVE-2026-33699"
    ];
  };
}
