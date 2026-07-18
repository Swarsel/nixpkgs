{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pytestCheckHook,
  rfc3987,
}:

buildPythonPackage rec {
  pname = "rfc3986-validator";
  version = "0.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-PUS955IbO57Drk463KNwQ47M68Z2RWRJsUXVM7JA0FU=";
    pname = "rfc3986_validator";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "'pytest-runner'," ""
  '';

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    rfc3987
  ];

  format = "setuptools";

  meta = {
    description = "Pure python rfc3986 validator";
    homepage = "https://github.com/naimetti/rfc3986-validator";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
