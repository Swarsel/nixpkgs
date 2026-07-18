{
  login,
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    substituteInPlace $BSDSRCDIR/libexec/getty/pathnames.h \
        --replace-fail "/usr/libexec/getty" "$out/bin/getty" \
        --replace-fail "/usr/bin/login" "${login}/bin/login"
  '';

  postInstall = ''
    mkdir -p $out/etc
    cp $BSDSRCDIR/etc/gettytab $out/etc/gettytab
  '';

  extraPaths = [ "etc/gettytab" ];
  path = "libexec/getty";
  meta.mainProgram = "getty";
}
