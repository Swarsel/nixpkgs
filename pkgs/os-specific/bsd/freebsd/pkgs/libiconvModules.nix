{
  csu,
  include,
  libcMinimal,
  libgcc,
  mkDerivation,
}:

mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  buildInputs = [
    include
    libcMinimal
    libgcc
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
    export makeFlags="$makeFlags SHLIBDIR=$out/lib/i18n"
  '';

  extraPaths = [
    "lib/libc/iconv"
  ];

  noLibc = true;
  path = "lib/libiconv_modules";
}
