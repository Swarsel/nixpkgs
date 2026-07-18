{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fstrm,
  gnutls,
  knot-dns,
  knot-resolver-manager_6,
  knot-resolver_5,
  libbpf,
  libcap_ng,
  libedit,
  libiconv,
  libidn2,
  libintl,
  libmaxminddb,
  libmnl,
  libunistring,
  liburcu,
  lmdb,
  nettle,
  nghttp2,
  ngtcp2-gnutls,
  nixosTests,
  pkg-config,
  protobufc,
  runCommandLocal,
  sphinx,
  systemd,
  xdp-tools,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "knot-dns";
  version = "3.5.5";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/knot-${finalAttrs.version}.tar.xz";
    sha256 = "38502c1472247c955aa3329bb5722e61ca765b833e3497d71f891ebf8e77fa04";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  patches = [
    # Don't try to create directories like /var/lib/knot at build time.
    # They are later created from NixOS itself.
    ./dont-create-run-time-dirs.patch
    ./runtime-deps.patch
  ];

  strictDeps = true;

  # FIXME: sphinx is needed for now to get man-pages
  nativeBuildInputs = [
    pkg-config
    protobufc # dnstap support
    autoreconfHook
    sphinx
  ];

  buildInputs = [
    gnutls
    liburcu
    libidn2
    libunistring
    nettle
    libedit
    libiconv
    lmdb
    libintl
    nghttp2 # DoH support in kdig
    ngtcp2-gnutls # DoQ support in kdig (and elsewhere but not much use there yet)
    libmaxminddb # optional for geoip module (it's tiny)
    # without sphinx &al. for developer documentation
    fstrm
    protobufc # dnstap support
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libcap_ng
    systemd
    xdp-tools
    libbpf
    libmnl # XDP support (it's Linux kernel API)
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin zlib; # perhaps due to gnutls

  configureFlags = [
    "--with-configdir=/etc/knot"
    "--with-rundir=/run/knot"
    "--with-storage=/var/lib/knot"
    "--with-module-dnstap"
    "--enable-dnstap"
  ];

  env.CFLAGS = toString [
    "-O2"
    "-DNDEBUG"
  ];

  doCheck = true;
  checkFlags = [ "V=1" ]; # verbose output in case some test fails

  postInstall = ''
    rm -r "$out"/lib/*.la
  '';

  doInstallCheck = true;
  __darwinAllowLocalNetworking = true;
  enableParallelBuilding = true;

  passthru.tests = {
    inherit knot-resolver_5;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isLinux {
    inherit knot-resolver-manager_6; # not very reliable on non-Linux yet
    inherit (nixosTests) knot kea;

    # Some dependencies are very version-sensitive, so the might get dropped
    # or embedded after some update, even if the nixPackagers didn't intend to.
    # For non-linux I don't know a good replacement for `ldd`.
    deps = runCommandLocal "knot-deps-test" { nativeBuildInputs = [ (lib.getBin stdenv.cc.libc) ]; } ''
      for libname in libngtcp2 libxdp libbpf; do
        echo "Checking for $libname:"
        ldd '${knot-dns.bin}/bin/knotd' | grep -F "$libname"
        echo "OK"
      done
      touch "$out"
    '';

    prometheus-exporter = nixosTests.prometheus-exporters.knot;
  };

  meta = {
    description = "Authoritative-only DNS server from .cz domain registry";
    homepage = "https://knot-dns.cz";
    changelog = "https://gitlab.nic.cz/knot/knot-dns/-/releases/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.vcunat ];
    platforms = lib.platforms.unix;
    mainProgram = "knotd";
  };
})
