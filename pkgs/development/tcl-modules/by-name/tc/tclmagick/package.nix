{
  lib,
  fetchzip,
  graphicsmagick,
  mkTclDerivation,
  tcl,
  tk,
}:

mkTclDerivation rec {
  pname = "tclmagick";
  version = "1.3.43";

  src = fetchzip {
    url = "mirror://sourceforge/graphicsmagick/GraphicsMagick-${version}.tar.xz";
    hash = "sha256-CpZztiBF0HqH4XWIAyE9IbZVpBcgrDzyASv47wTneQ0=";
  };

  buildInputs = [
    graphicsmagick
    tk
  ];

  configureFlags = [
    "--with-tk=${lib.getLib tk}/lib"
    "--with-tkinclude=${lib.getDev tk}/include"
  ];

  doInstallCheck = true;
  sourceRoot = src.name + "/TclMagick";

  meta = {
    description = "Tcl and Tk Interfaces to GraphicsMagick and ImageMagick";
    homepage = "http://www.graphicsmagick.org/TclMagick/doc/";
    license = lib.licenses.tcltk;
    maintainers = with lib.maintainers; [ fgaz ];
    broken = tcl.isTcl9;
  };
}
