{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docopt,
  openstep-parser,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pbxproj";
  version = "4.3.3";

  src = fetchFromGitHub {
    owner = "kronenthaler";
    repo = "mod-pbxproj";
    tag = version;
    hash = "sha256-Gb3JeMONOkQWm3pv2EXIU4aw1HJQiiYSr94sjTFVF/Q=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    docopt
    openstep-parser
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pbxproj"
    "openstep_parser"
  ];

  meta = {
    description = "Python module to manipulate XCode projects ";
    homepage = "https://github.com/kronenthaler/mod-pbxproj";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ilaumjd ];
  };
}
