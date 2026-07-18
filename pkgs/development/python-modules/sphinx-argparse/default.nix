{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  lxml,
  pytestCheckHook,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinx-argparse";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-0HK7Z91SspQ3Xw7twgPLjlDQMpkQ2862dk6Thr/5Tp0=";
    pname = "sphinx_argparse";
  };

  nativeCheckInputs = [
    lxml
    pytestCheckHook
  ];

  build-system = [ flit-core ];
  dependencies = [ sphinx ];
  pyproject = true;
  pythonImportsCheck = [ "sphinxarg" ];

  meta = {
    description = "Sphinx extension that automatically documents argparse commands and options";
    homepage = "https://github.com/ashb/sphinx-argparse";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ clacke ];
  };
}
