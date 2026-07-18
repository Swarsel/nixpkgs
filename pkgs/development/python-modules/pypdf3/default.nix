{
  lib,
  buildPythonPackage,
  fetchPypi,
  glibcLocales,
  python,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pypdf3";
  version = "1.0.6";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-yUbzJzQZ43JY415yJz9JkEqxVyPYenYcERXvmXmfjF8=";
    pname = "PyPDF3";
  };

  buildInputs = [ glibcLocales ];
  propagatedBuildInputs = [ tqdm ];
  env.LC_ALL = "en_US.UTF-8";

  checkPhase = ''
    ${python.interpreter} -m unittest tests/*.py
  '';

  format = "setuptools";

  meta = {
    description = "Pure-Python library built as a PDF toolkit";
    homepage = "https://github.com/sfneal/PyPDF3";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ambroisie ];

    knownVulnerabilities = [
      "CVE-2026-27024"
      "CVE-2026-27025"
      "CVE-2026-27628"
      "CVE-2026-27888"
      "CVE-2026-28351"
      "CVE-2026-33699"
    ];
  };
})
