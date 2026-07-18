{
  lib,
  stdenv,
  fetchurl,
  docutils,
  libev,
  nixosTests,
  openssl,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hitch";
  version = "1.8.0";

  src = fetchurl {
    url = "https://hitch-tls.org/source/hitch-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-38mUhLx//qJ6MWnoTWwheYjtpHsgirLlUk3Cpd0Vj04=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    docutils
    libev
    openssl
  ];

  passthru.tests.hitch = nixosTests.hitch;

  meta = {
    description = "Libev-based high performance SSL/TLS proxy by Varnish Software";
    homepage = "https://hitch-tls.org/";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.jflanglois ];
    platforms = lib.platforms.linux;
    mainProgram = "hitch";
  };
})
