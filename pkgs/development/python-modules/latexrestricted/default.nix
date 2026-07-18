{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "latexrestricted";
  version = "0.6.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1R0hpBGXpYH/KcD4GFUfFvoOaJDe+Sl5msC952KnqmA=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "latexrestricted" ];

  meta = {
    description = "Python library for creating executables compatible with LaTeX restricted shell escape";
    homepage = "https://github.com/gpoore/latexrestricted";
    changelog = "https://github.com/gpoore/latexrestricted/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.lppl13c;
    maintainers = with lib.maintainers; [ romildo ];
  };
}
