{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-katex";
  version = "0.9.11";

  src = fetchPypi {
    inherit version;
    hash = "sha256-LTKyENILvuRRpR0ZZF9v719VaLmlTigTr/uW76ZhI4o=";
    pname = "sphinxcontrib_katex";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ sphinx ];
  pyproject = true;
  pythonImportsCheck = [ "sphinxcontrib.katex" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx extension using KaTeX to render math in HTML";
    homepage = "https://github.com/hagenw/sphinxcontrib-katex";
    changelog = "https://github.com/hagenw/sphinxcontrib-katex/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
