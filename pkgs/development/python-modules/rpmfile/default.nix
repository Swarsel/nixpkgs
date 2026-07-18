{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
}:
buildPythonPackage rec {
  pname = "rpmfile";
  version = "2.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CsK7qJJ3xxhcuGHJxtfQyaJovlFpUW28amjxVWqeP5k=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  # Tests access the internet
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "rpmfile" ];

  meta = {
    description = "Read rpm archive files";
    homepage = "https://github.com/srossross/rpmfile";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "rpmfile";
  };
}
