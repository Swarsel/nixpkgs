{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "update-copyright";
  version = "0.6.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "17ybdgbdc62yqhda4kfy1vcs1yzp78d91qfhj5zbvz1afvmvdk7z";
  };

  # Has no tests
  doCheck = false;
  disabled = !isPy3k;
  format = "setuptools";

  meta = {
    description = "Automatic copyright update tool";
    homepage = "http://blog.tremily.us/posts/update-copyright";
    license = lib.licenses.gpl3;
    mainProgram = "update-copyright.py";
  };
}
