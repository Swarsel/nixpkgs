{
  lib,
  fetchurl,
  mkTclDerivation,
  tk,
}:

mkTclDerivation rec {
  pname = "bwidget";
  version = "1.10.0";

  src = fetchurl {
    url = "mirror://sourceforge/tcllib/bwidget-${version}.tar.gz";
    sha256 = "sha256-61sCvsua+Iv3SldHhd4eMpzzCjZ5EVMJOnkRT6xRw60=";
  };

  propagatedBuildInputs = [ tk ];

  installPhase = ''
    mkdir -p "$out/lib/bwidget${version}"
    cp -R *.tcl lang images "$out/lib/bwidget${version}"
  '';

  dontBuild = true;

  meta = {
    description = "High-level widget set for Tcl/Tk";
    homepage = "https://sourceforge.net/projects/tcllib";
    license = lib.licenses.tcltk;
    maintainers = with lib.maintainers; [ agbrooks ];
    platforms = lib.platforms.unix;
  };
}
