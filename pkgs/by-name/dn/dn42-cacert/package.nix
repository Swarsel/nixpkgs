{
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "dn42-cacert";
  # check it on its homepage
  version = "0-unstable-2016-01-16";
  src = ./root-ca.crt;

  installPhase = ''
    install -Dm644 $src $out/etc/ssl/certs/dn42-ca.crt
  '';

  dontBuild = true;
  dontUnpack = true;

  meta = {
    description = "DN42 Root CA certificate";
    homepage = "https://wiki.dn42.dev/services/Certificate-Authority.md";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ Cryolitia ];
    platforms = lib.platforms.all;
  };
}
