{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-protocol";
  version = "0.0.18";

  # Not available vis Github yet; required by langchain-core
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7D4ReC8e0MnbOOWp7QGw56DT+6QG+qiu9llLc8VqY+Y=";
    pname = "langchain_protocol";
  };

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "langchain_protocol"
  ];

  meta = {
    description = "Python bindings for the LangChain agent streaming protocol";
    homepage = "https://pypi.org/project/langchain-protocol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
