{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "progressbar33";
  version = "2.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1zvf6zs5hzrc03p9nfs4p16vhilqikycvv1yk0pxn8s07fdhvzji";
  };

  # no tests implemented
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Text progressbar library for python";
    homepage = "https://pypi.org/project/progressbar33/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ twey ];
  };
}
