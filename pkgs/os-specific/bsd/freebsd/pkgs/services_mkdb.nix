{ mkDerivation }:
mkDerivation {
  postInstall = ''
    mkdir -p $out/etc
    cp $BSDSRCDIR/usr.sbin/services_mkdb/services $out/etc/services
  '';

  path = "usr.sbin/services_mkdb";
}
