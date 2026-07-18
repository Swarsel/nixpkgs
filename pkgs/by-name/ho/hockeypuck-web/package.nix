{
  lib,
  stdenv,
  hockeypuck,
  nixosTests,
}:

stdenv.mkDerivation {
  inherit (hockeypuck) version src;
  pname = "hockeypuck-web";

  installPhase = ''
    mkdir -p $out/share/

    cp -vr contrib/webroot $out/share/
    cp -vr contrib/templates $out/share/
  '';

  dontBuild = true; # We should just copy the web templates
  passthru.tests = nixosTests.hockeypuck;

  meta = {
    description = "OpenPGP Key Server web resources";
    homepage = "https://github.com/hockeypuck/hockeypuck";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
