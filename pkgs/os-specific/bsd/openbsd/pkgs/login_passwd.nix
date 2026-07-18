{
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -i 's/4555/0555/' $BSDSRCDIR/libexec/login_passwd/Makefile
  '';

  path = "libexec/login_passwd";
}
