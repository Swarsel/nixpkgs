{
  lib,
  stdenv,
  fetchurl,
  libidn,
  libkrb5,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gsasl";
  version = "2.2.3";

  src = fetchurl {
    url = "mirror://gnu/gsasl/gsasl-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-/uNsZqwS0y078pp7Na2PREt5lv42m52l02/WrmScaOs=";
  };

  buildInputs = [
    libidn
    libkrb5
  ];

  configureFlags = [ "--with-gssapi-impl=mit" ];
  doCheck = !stdenv.hostPlatform.isDarwin;

  preCheck = ''
    export LOCALDOMAIN="dummydomain"
  '';

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "GNU SASL, Simple Authentication and Security Layer library";

    longDescription = ''
      GNU SASL is a library that implements the IETF Simple
      Authentication and Security Layer (SASL) framework and
      some SASL mechanisms. SASL is used in network servers
      (e.g. IMAP, SMTP, etc.) to authenticate peers.
    '';

    homepage = "https://www.gnu.org/software/gsasl/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ shlevy ];
    platforms = lib.platforms.all;
    mainProgram = "gsasl";
    pkgConfigModules = [ "libgsasl" ];
  };
})
