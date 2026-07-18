{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pyasn1,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pgpy-dtc";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "DigitalTrustCenter";
    repo = "PGPy_dtc";
    tag = version;
    hash = "sha256-0zv2gtgp/iGDQescaDpng1gqbgjv7iXFvtwEt3YIPy4=";
  };

  patches = [
    # NOTE: This is the same patch file as Fix-compat-with-current-cryptography.patch
    #       from the pgpy packaging, with the base directory modified for pgpy-dtc.
    # https://github.com/SecurityInnovation/PGPy/pull/474
    ./Fix-compat-with-current-cryptography.patch
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    pyasn1
    cryptography
  ];

  pyproject = true;
  pythonImportsCheck = [ "pgpy_dtc" ];

  meta = {
    description = "Pretty Good Privacy for Python";
    homepage = "https://github.com/DigitalTrustCenter/PGPy_dtc";
    changelog = "https://github.com/DigitalTrustCenter/PGPy_dtc/releases/tag/${src.tag}";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ networkexception ];
  };
}
