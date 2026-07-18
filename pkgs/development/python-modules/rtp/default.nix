{
  lib,
  buildPythonPackage,
  fetchPypi,

  # nativeCheckInputs
  hypothesis,
  unittestCheckHook,

}:

buildPythonPackage rec {
  pname = "rtp";
  version = "0.0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-I5k3uF5lSLDdCWjBEQC4kl2dWyAKcHEJIYwqnEvJDBI=";
  };

  nativeCheckInputs = [
    hypothesis
    unittestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "rtp" ];

  unittestFlagsArray = [
    "-s"
    "tests"
    "-v"
  ];

  meta = {
    description = "Library for decoding/encoding rtp packets";
    homepage = "https://github.com/bbc/rd-apmm-python-lib-rtp";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fleaz ];
  };
}
