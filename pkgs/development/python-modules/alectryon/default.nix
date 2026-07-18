{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  docutils,
  dominate,
  fetchPypi,
  myst-parser,
  pygments,
  setuptools,
  sphinx,
}:

buildPythonPackage (finalAttrs: {
  pname = "alectryon";
  version = "2.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "sha256-ouuCwipCQKSlH8NpF5QZd4jx4mEYooyIcnRhtDRWOnU=";
  };

  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pygments
    dominate
    beautifulsoup4
    docutils
    myst-parser
    sphinx
  ];

  pyproject = true;
  pythonImportsCheck = [ "alectryon" ];

  meta = {
    description = "Collection of tools for writing technical documents that mix Coq code and prose";
    homepage = "https://github.com/cpitclaudel/alectryon";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zimmi48 ];
    mainProgram = "alectryon";
  };
})
