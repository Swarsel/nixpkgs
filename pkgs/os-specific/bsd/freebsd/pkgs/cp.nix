{ mkDerivation }:
mkDerivation {
  postPatch = ''
    substituteInPlace $BSDSRCDIR/bin/cp/Makefile --replace 'tests' ""
  '';

  extraPaths = [ "sys" ];
  path = "bin/cp";
}
