{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libircclient";
  version = "1.10";

  src = fetchurl {
    url = "mirror://sourceforge/libircclient/libircclient/${finalAttrs.version}/libircclient-${finalAttrs.version}.tar.gz";
    sha256 = "0b9wa0h3xc31wpqlvgxgnvqp5wgx3kwsf5s9432m5cj8ycx6zcmv";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace src/Makefile.in \
      --replace "@prefix@/include" "@prefix@/include/libircclient" \
      --replace "@libdir@"         "@prefix@/lib" \
      --replace "cp "              "install "
  '';

  configureFlags = [ "--enable-shared" ];

  meta = {
    description = "Small but extremely powerful library which implements the client IRC protocol";
    homepage = "http://www.ulduzsoft.com/libircclient/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ obadz ];
    platforms = lib.platforms.linux;
  };
})
