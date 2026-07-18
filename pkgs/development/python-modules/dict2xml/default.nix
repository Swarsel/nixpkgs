{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
}:

buildPythonPackage rec {
  pname = "dict2xml";
  version = "1.7.8";

  src = fetchFromGitHub {
    owner = "delfick";
    repo = "python-dict2xml";
    tag = "release-${version}";
    hash = "sha256-wCspFcqn6uAvecxx4Agzg7N3ps82mg8ukmmGwhfgajk=";
  };

  nativeBuildInputs = [ hatchling ];
  # Tests are implemented in a custom DSL (RSpec)
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "dict2xml" ];

  meta = {
    description = "Library to convert a Python dictionary into an XML string";
    homepage = "https://github.com/delfick/python-dict2xml";
    changelog = "https://github.com/delfick/python-dict2xml/releases/tag/release-${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ johnazoidberg ];
  };
}
