{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qprint";
  version = "1.1";

  src = fetchurl {
    url = "https://www.fourmilab.ch/webtools/qprint/qprint-${finalAttrs.version}.tar.gz";
    sha256 = "1701cnb1nl84rmcpxzq11w4cyj4385jh3gx4aqxznwf8a4fwmagz";
  };

  doCheck = true;

  preInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
  '';

  checkTarget = "wringer";

  meta = {
    description = "Encode and decode Quoted-Printable files";
    homepage = "https://www.fourmilab.ch/webtools/qprint/";
    license = lib.licenses.publicDomain;
    maintainers = [ lib.maintainers.tv ];
    platforms = lib.platforms.all;
    mainProgram = "qprint";
  };

})
