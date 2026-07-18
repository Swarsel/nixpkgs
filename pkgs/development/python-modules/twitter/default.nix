{
  lib,
  buildPythonPackage,
  certifi,
  fetchPypi,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "twitter";
  version = "1.19.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gN3WmuLuuIMT/u3uoxvxGf1ueVQe5bN6u5xD0jMZThA=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ certifi ];
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "twitter" ];

  meta = {
    description = "Twitter API library";
    homepage = "https://mike.verdone.ca/twitter/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thoughtpolice ];
  };
}
