{
  lib,

  buildPythonPackage,
  notmuch,
  python,
}:

buildPythonPackage {
  inherit (notmuch) pname version src;

  postPatch = ''
    sed -i -e '/CDLL/s@"libnotmuch\.@"${notmuch}/lib/libnotmuch.@' \
      notmuch/globals.py
  '';

  buildInputs = [
    python
    notmuch
  ];

  # no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "notmuch" ];
  sourceRoot = notmuch.pythonSourceRoot;

  meta = {
    description = "Python wrapper around notmuch";
    homepage = "https://notmuchmail.org/";
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
}
