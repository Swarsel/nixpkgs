{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "chainstream";
  version = "1.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-syl107PRwDClB6wpgETCj6PKMNUnq9+uKB7dUydmF7M=";
  };

  nativeBuildInputs = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "chainstream" ];

  meta = {
    description = "Chain I/O streams together into a single stream";
    homepage = "https://github.com/rrthomas/chainstream";
    license = lib.licenses.cc-by-sa-40;
    maintainers = with lib.maintainers; [ cbley ];
  };
}
