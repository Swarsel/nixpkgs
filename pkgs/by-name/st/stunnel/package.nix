{
  lib,
  stdenv,
  fetchurl,
  mimalloc,
  nixosTests,
  openssl,
  systemdLibs,
  mimallocSupport ? false,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stunnel";
  version = "5.79";

  src = fetchurl {
    url = "https://www.stunnel.org/archive/${lib.versions.major finalAttrs.version}.x/stunnel-${finalAttrs.version}.tar.gz";
    hash = "sha256-jqDebl6nbzjqmH+oMcf9R/eh8efdRl/W+oYi7fMNOkU=";
    # please use the contents of "https://www.stunnel.org/downloads/stunnel-${version}.tar.gz.sha256",
    # not the output of `nix-prefetch-url`
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals systemdSupport [
    systemdLibs
  ]
  ++ lib.optionals mimallocSupport [
    mimalloc
  ];

  configureFlags = [
    "--with-ssl=${openssl.dev}"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    (lib.enableFeature systemdSupport "systemd")
  ];

  postInstall = ''
    # remove legacy compatibility-wrapper that would require perl
    rm $out/bin/stunnel3
  '';

  enableParallelBuilding = true;

  installFlags = [
    "sysconfdir=\${out}/etc"
    "localstatedir=\${TMPDIR}"
  ];

  passthru.tests = {
    stunnel = nixosTests.stunnel;
  };

  meta = {
    description = "Universal tls/ssl wrapper";
    homepage = "https://www.stunnel.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.thoughtpolice ];
    platforms = lib.platforms.unix;
    mainProgram = "stunnel";
  };
})
