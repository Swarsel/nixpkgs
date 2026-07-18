{
  compatIfNeeded,
  libsbuf,
  mkDerivation,
}:
mkDerivation {
  # The only subdir is newsyslog.conf.d, all config files we don't want
  postPatch = ''
    sed -E -i -e '/^SUBDIR/d' $BSDSRCDIR/usr.sbin/newsyslog/Makefile
  '';

  buildInputs = compatIfNeeded ++ [ libsbuf ];
  path = "usr.sbin/newsyslog";
}
