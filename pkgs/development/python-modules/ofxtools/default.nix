{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "ofxtools";
  version = "0.9.5";

  # PyPI distribution does not include tests
  src = fetchFromGitHub {
    owner = "csingley";
    repo = "ofxtools";
    rev = version;
    hash = "sha256-NsImnD+erhpakQnl1neuHfSKiV6ipNBMPGKMDM0gwWc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # override $HOME directory:
  #   error: [Errno 13] Permission denied: '/homeless-shelter'
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  format = "setuptools";

  meta = {
    description = "Library for working with Open Financial Exchange (OFX) formatted data used by financial institutions";
    homepage = "https://github.com/csingley/ofxtools";
    license = lib.licenses.mit;
    mainProgram = "ofxget";
  };
}
