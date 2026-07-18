{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  streamlit,
}:

buildPythonPackage rec {
  pname = "streamlit-card";
  version = "1.0.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-gAHNXt2Kbi2zbugfN9xkXwj3jCGiupaEAxdsaLTzPLE=";
    pname = "streamlit_card";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ streamlit ];
  pyproject = true;
  pythonImportsCheck = [ "streamlit_card" ];

  meta = {
    description = "Streamlit component to make UI cards";
    homepage = "https://github.com/gamcoh/st-card";
    changelog = "https://github.com/gamcoh/st-card/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
