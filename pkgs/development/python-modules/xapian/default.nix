{
  lib,
  fetchurl,
  buildPythonPackage,
  python,
  sphinx,
  xapian,
}:

let
  pythonSuffix = lib.optionalString python.isPy3k "3";
in
buildPythonPackage rec {
  inherit (xapian) version;
  pname = "xapian";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/xapian-bindings-${version}.tar.xz";
    hash = "sha256-o4zHukGIzAvSfcc2nwOQZ3IEcIehxU8bkzVdXpEDwwQ=";
  };

  buildInputs = [
    sphinx
    xapian
  ];

  configureFlags = [
    "--with-python${pythonSuffix}"
    "PYTHON${pythonSuffix}_LIB=${placeholder "out"}/${python.sitePackages}"
  ];

  preConfigure = ''
    export XAPIAN_CONFIG=${xapian}/bin/xapian-config
  '';

  checkPhase = ''
    ${python.interpreter} python${pythonSuffix}/pythontest.py
  '';

  pyproject = false;

  meta = {
    description = "Python Bindings for Xapian";
    homepage = "https://xapian.org/";
    changelog = "https://xapian.org/docs/xapian-bindings-${version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
}
