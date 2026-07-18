{
  libncurses,
  libncurses-form,
  libncurses-tinfo,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    libncurses
    libncurses-form
    libncurses-tinfo
  ];

  postFixup = ''
    mv $out/include/private/bsddialog/* $out/include
    rm -rf $out/include/private
  '';

  extraPaths = [
    "contrib/bsddialog"
  ];

  path = "lib/libbsddialog";
}
