{
  login,
  mkDerivation,
  wrappedLogin ? null,
}:
mkDerivation {
  postPatch = ''
    sed -E -i -e "s|/usr/bin/login|${
      if (wrappedLogin != null) then wrappedLogin else "${login}/bin/login"
    }|g" $BSDSRCDIR/libexec/getty/*.h
  '';

  postInstall = ''
    mkdir -p $out/etc
    cp $BSDSRCDIR/libexec/getty/gettytab $out/etc/gettytab
  '';

  MK_TESTS = "no";
  path = "libexec/getty";
}
