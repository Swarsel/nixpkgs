{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ofxhome";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "captin411";
    repo = "ofxhome";
    rev = "v${version}";
    hash = "sha256-i16bE9iuafhAKco2jYfg5T5QCWFHdnYVztf1z2XbO9g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  # These are helper functions that should not be called as tests
  disabledTests = [
    "testfile_name"
    "testfile"
  ];

  pyproject = true;

  meta = {
    description = "ofxhome.com financial institution lookup REST client";
    homepage = "https://github.com/captin411/ofxhome";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
