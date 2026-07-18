{
  libnv,
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -E -i -e '/INTERNALLIB/d' lib/libnvmf/Makefile
  '';

  buildInputs = [ libnv ];

  postInstall = ''
    ln -s libnvmf.a $out/lib/libnvmf_pie.a
  '';

  alwaysKeepStatic = true;

  extraPaths = [
    "sys/libkern"
    "sys/dev/nvmf"
  ];

  path = "lib/libnvmf";
}
