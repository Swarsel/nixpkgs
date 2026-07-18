{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  streamlit,
}:

buildPythonPackage rec {
  pname = "extra-streamlit-components";
  version = "0.1.81";

  src = fetchPypi {
    inherit version;
    hash = "sha256-65vre6z+iz0jjxiIohx4rGz6VpNBvkhLygjD6gsV8g0=";
    pname = "extra_streamlit_components";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ streamlit ];
  pyproject = true;
  pythonImportsCheck = [ "extra_streamlit_components" ];

  meta = {
    description = "Additional components for streamlit";
    homepage = "https://pypi.org/project/extra-streamlit-components/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
