{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  chardet,
  faker,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "mbstrdecoder";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "thombashi";
    repo = "mbstrdecoder";
    tag = "v${version}";
    hash = "sha256-RPtxoI4fFiBHBOWOdGueVjPPOAUjDThawS80SIoTQ78=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [ chardet ];
  nativeCheckInputs = [ pytestCheckHook ];
  checkInputs = [ faker ];
  pyproject = true;

  meta = {
    description = "Library for decoding multi-byte character strings";
    homepage = "https://github.com/thombashi/mbstrdecoder";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
