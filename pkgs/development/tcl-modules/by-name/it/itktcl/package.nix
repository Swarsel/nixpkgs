{
  lib,
  stdenv,
  fetchurl,
  incrtcl,
  mkTclDerivation,
  tk,
}:

mkTclDerivation rec {
  pname = "itk-tcl";
  version = "4.1.0";

  src = fetchurl {
    url = "mirror://sourceforge/incrtcl/%5BIncr%20Tcl_Tk%5D-source/3.4/itk${version}.tar.gz";
    hash = "sha256-2mRhmSIu/cTYyZWThjyNKHRC6lqGh/lUYNbp5yQxycc=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  buildInputs = [
    tk
    incrtcl
  ];

  configureFlags = [
    "--with-tk=${tk}/lib"
    "--with-itcl=${incrtcl}/lib"
    "--with-tkinclude=${tk.dev}/include"
  ];

  postInstall = ''
    rmdir $out/bin
    mv $out/lib/itk${version}/* $out/lib
    ln -s libitk${version}${stdenv.hostPlatform.extensions.sharedLibrary} \
      $out/lib/libitk${lib.versions.major version}${stdenv.hostPlatform.extensions.sharedLibrary}
    rmdir $out/lib/itk${version}
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Mega-widget toolkit for incr Tk";
    homepage = "https://incrtcl.sourceforge.net/";
    license = lib.licenses.tcltk;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.unix;
  };
}
