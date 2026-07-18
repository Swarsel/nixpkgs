{
  lib,
  buildPythonPackage,
  cssutils,
  fetchPypi,
  whey,
}:
buildPythonPackage rec {
  pname = "dict2css";
  version = "0.3.0.post1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-icVEwhxMp0csP/+50309km9gYymv23Udwd5npBG3Bxk=";
    pname = "dict2css";
  };

  build-system = [ whey ];
  dependencies = [ cssutils ];
  pyproject = true;
  pythonImportsCheck = [ "dict2css" ];

  meta = {
    description = "μ-library for constructing cascading style sheets from Python dictionaries";
    homepage = "https://github.com/sphinx-toolbox/dict2css";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
