{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  openssl,
  perlPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sslmate";
  version = "1.10.0";

  src = fetchurl {
    url = "https://packages.sslmate.com/other/sslmate-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-yjeK/CjFSjjymriVb41AWy0SSJ5mwPp6T+asyHaeX5E=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perlPackages.perl ];
  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/sslmate --prefix PERL5LIB : \
      "${
        with perlPackages;
        makePerlPath [
          URI
          JSONPP
          TermReadKey
        ]
      }" \
      --prefix PATH : "${openssl.bin}/bin"
  '';

  meta = {
    description = "Easy to buy, deploy, and manage your SSL certs";
    homepage = "https://sslmate.com";
    license = lib.licenses.mit; # X11
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "sslmate";
  };
})
