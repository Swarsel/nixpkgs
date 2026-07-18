{
  lndir,
  msp430GccSupport,
  newlib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  inherit (newlib) version;
  inherit newlib;
  inherit msp430GccSupport;
  pname = "msp430-${newlib.pname}";
  allowSubstitutes = false;

  buildCommand = ''
    mkdir $out
    ${lndir}/bin/lndir -silent $newlib $out
    ${lndir}/bin/lndir -silent $msp430GccSupport/include $out/${newlib.incdir}
    ${lndir}/bin/lndir -silent $msp430GccSupport/lib $out/${newlib.libdir}
  '';

  preferLocalBuild = true;

  passthru = {
    inherit (newlib) incdir libdir;
  };

  meta = {
    platforms = [ "msp430-none" ];
  };
}
