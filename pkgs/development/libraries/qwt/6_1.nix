{
  lib,
  stdenv,
  fetchurl,
  qmake,
  qtbase,
  qtsvg,
  qttools,
}:

stdenv.mkDerivation rec {
  pname = "qwt";
  version = "6.1.6";

  src = fetchurl {
    url = "mirror://sourceforge/qwt/qwt-${version}.tar.bz2";
    sha256 = "sha256-mUYNMcEV7kEXsBddiF9HwsWQ14QgbwmBXcBY++Xt4fY=";
  };

  postPatch = ''
    sed -e "s|QWT_INSTALL_PREFIX.*=.*|QWT_INSTALL_PREFIX = $out|g" -i qwtconfig.pri
  '';

  nativeBuildInputs = [ qmake ];

  propagatedBuildInputs = [
    qtbase
    qtsvg
    qttools
  ];

  dontWrapQtApps = true;
  qmakeFlags = [ "-after doc.path=$out/share/doc/qwt-${version}" ];

  meta = {
    description = "Qt widgets for technical applications";
    homepage = "http://qwt.sourceforge.net/";

    # LGPL 2.1 plus a few exceptions (more liberal)
    license = with lib.licenses; [
      lgpl21Only
      qwtException
    ];

    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.unix;
  };
}
