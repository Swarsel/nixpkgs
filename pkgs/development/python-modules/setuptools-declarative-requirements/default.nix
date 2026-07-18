{
  lib,
  buildPythonPackage,
  fetchPypi,
  pypiserver,
  pytestCheckHook,
  setuptools-scm,
  virtualenv,
}:

buildPythonPackage rec {
  pname = "setuptools-declarative-requirements";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-V6W5u5rTUMJ46Kpr5M3rvNklubpx1qcSoXimGM+4mPc=";
  };

  buildInputs = [ setuptools-scm ];
  # Tests use network
  doCheck = false;

  nativeCheckInputs = [
    pypiserver
    pytestCheckHook
    virtualenv
  ];

  format = "setuptools";
  pythonImportsCheck = [ "declarative_requirements" ];

  meta = {
    description = "Declarative setuptools Config Requirements Files Support";
    homepage = "https://github.com/s0undt3ch/setuptools-declarative-requirements";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.austinbutler ];
  };
}
