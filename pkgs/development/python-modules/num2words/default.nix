{
  lib,
  buildPythonPackage,
  delegator-py,
  docopt,
  fetchPypi,
  pytest,
}:

buildPythonPackage rec {
  pname = "num2words";
  version = "0.5.14";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-sGbsGOVrZhajs4CGtXR9qvuqiGiyJqNhJ+BFHAzzecY=";
  };

  propagatedBuildInputs = [ docopt ];

  nativeCheckInputs = [
    delegator-py
    pytest
  ];

  checkPhase = ''
    pytest -k 'not cli_with_lang'
  '';

  format = "setuptools";

  meta = {
    description = "Modules to convert numbers to words. 42 --> forty-two";
    longDescription = "num2words is a library that converts numbers like 42 to words like forty-two. It supports multiple languages (see the list below for full list of languages) and can even generate ordinal numbers like forty-second";
    homepage = "https://github.com/savoirfairelinux/num2words";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    mainProgram = "num2words";
  };
}
