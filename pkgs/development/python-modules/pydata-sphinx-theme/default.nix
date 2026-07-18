{
  lib,
  accessible-pygments,
  beautifulsoup4,
  buildPythonPackage,
  docutils,
  fetchPypi,
  packaging,
  sphinx,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pydata-sphinx-theme";
  version = "0.16.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-IlMx6KxLMmgsGPysWlem9xfE5jLOpd0OJHtVFV+uzN4=";
    dist = "py3";
    format = "wheel";
    pname = "pydata_sphinx_theme";
    python = "py3";
  };

  propagatedBuildInputs = [
    sphinx
    accessible-pygments
    beautifulsoup4
    docutils
    packaging
    typing-extensions
  ];

  format = "wheel";
  pythonImportsCheck = [ "pydata_sphinx_theme" ];

  meta = {
    description = "Bootstrap-based Sphinx theme from the PyData community";
    homepage = "https://github.com/pydata/pydata-sphinx-theme";
    changelog = "https://github.com/pydata/pydata-sphinx-theme/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
