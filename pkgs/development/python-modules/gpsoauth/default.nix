{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  pycryptodomex,
  requests,
}:

buildPythonPackage rec {
  pname = "gpsoauth";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-njt2WmpOA2TewbxBV70+1+XsMGZYnihdC0aYaRCqa9I=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    pycryptodomex
    requests
  ];

  # upstream tests are not very comprehensive
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "gpsoauth" ];
  pythonRelaxDeps = [ "urllib3" ];

  meta = {
    description = "Library for Google Play Services OAuth";
    homepage = "https://github.com/simon-weber/gpsoauth";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jgillich ];
  };
}
