{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  fsspec,
  oci,
  requests,
}:

buildPythonPackage rec {
  pname = "ocifs";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "oracle";
    repo = "ocifs";
    tag = "v${version}";
    hash = "sha256-IGl9G4NyzhcqrfYfgeZin+wt1OwHmh6780MPfZBwsXA=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ flit-core ];

  dependencies = [
    fsspec
    oci
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "ocifs" ];

  meta = {
    description = "Oracle Cloud Infrastructure Object Storage fsspec implementation";
    homepage = "https://ocifs.readthedocs.io";
    changelog = "https://github.com/oracle/ocifs/releases/tag/v${version}";
    license = lib.licenses.upl;
    maintainers = with lib.maintainers; [ fab ];
  };
}
