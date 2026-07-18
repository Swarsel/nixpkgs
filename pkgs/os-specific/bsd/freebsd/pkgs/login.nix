{
  cap_mkdb,
  libbsm,
  libpam,
  libutil,
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -E -i -e "s|..DESTDIR./etc|\''${CONFDIR}|g" $BSDSRCDIR/usr.bin/login/Makefile
  '';

  buildInputs = [
    libutil
    libpam
    libbsm
  ];

  postInstall = ''
    mkdir -p $out/etc
    make $makeFlags installconfig
  '';

  MK_SETUID_LOGIN = "no";
  MK_TESTS = "no";
  extraNativeBuildInputs = [ cap_mkdb ];
  path = "usr.bin/login";
}
