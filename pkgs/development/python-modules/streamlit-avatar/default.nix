{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  streamlit,
}:

buildPythonPackage rec {
  pname = "streamlit-avatar";
  version = "0.1.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-AjiTvYDbWpI9OX/GTSfHqXIQfaTwvqD+uZoy+TY/JpE=";
    pname = "streamlit_avatar";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ streamlit ];
  pyproject = true;
  pythonImportsCheck = [ "streamlit_avatar" ];

  meta = {
    description = "Component to display avatar icon in Streamlit";
    homepage = "https://pypi.org/project/streamlit-avatar/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
