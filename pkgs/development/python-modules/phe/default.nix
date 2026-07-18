{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  gmpy2,
  isPy3k,
  isPyPy,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "phe";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "data61";
    repo = "python-paillier";
    tag = finalAttrs.version;
    hash = "sha256-P//4ZL4+2zcB5sWvujs2N0CHFz+EBLERWrPGLLHj6CY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    numpy
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    gmpy2 # optional, but major speed improvement
  ];

  # https://github.com/data61/python-paillier/issues/51
  disabled = isPyPy || !isPy3k;
  pyproject = true;

  meta = {
    description = "Library for Partially Homomorphic Encryption in Python";
    homepage = "https://github.com/data61/python-paillier";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "pheutil";
  };
})
