{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "gemfileparser";
  version = "0.8.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-g5WS5J6j/Zhc7AA+9Y+OdwCaae12RKDArMlM9t2bjW4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "gemfileparser" ];

  meta = {
    description = "Library to parse Ruby Gemfile, .gemspec and Cocoapod .podspec file using Python";
    homepage = "https://github.com/gemfileparser/gemfileparser";

    license = with lib.licenses; [
      gpl3Plus
      mit
    ];

    maintainers = [ ];
    mainProgram = "parsegemfile";
  };
}
