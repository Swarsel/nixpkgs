{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  openssl,
  setuptools,
}:

buildPythonPackage rec {
  pname = "securestring";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "dnet";
    repo = "pysecstr";
    tag = "v${version}";
    hash = "sha256-FV5NUPberA5nqHad8IwkQLMldT1DPqTGpqOwgQ2zSdI=";
  };

  buildInputs = [ openssl ];
  # no upstream tests exist
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "SecureString" ];

  meta = {
    description = "Clears the contents of strings containing cryptographic material";
    homepage = "https://github.com/dnet/pysecstr";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ethancedwards8 ];
  };
}
