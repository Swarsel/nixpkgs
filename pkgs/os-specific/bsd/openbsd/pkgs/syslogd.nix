{
  libevent,
  libressl,
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -i /DPADD/d $BSDSRCDIR/usr.sbin/syslogd/Makefile
  '';

  buildInputs = [
    libressl
    libevent
  ];

  path = "usr.sbin/syslogd";
}
