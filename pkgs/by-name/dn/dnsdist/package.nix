{
  lib,
  stdenv,
  fetchurl,
  boost,
  cargo,
  fstrm,
  libbpf,
  libcap,
  libedit,
  libsodium,
  lua,
  net-snmp,
  nghttp2,
  nixosTests,
  openssl,
  pkg-config,
  protobuf,
  python3,
  re2,
  rustPlatform,
  systemd,
  xdp-tools,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dnsdist";
  version = "2.0.7";

  src = fetchurl {
    url = "https://downloads.powerdns.com/releases/dnsdist-${finalAttrs.version}.tar.xz";
    hash = "sha256-WGgPeAUXt4fmT+5M1NzFf0Ob5gcIT4nuRpl4nX1iaHU=";
  };

  nativeBuildInputs = [
    cargo
    pkg-config
    protobuf
    python3
    python3.pkgs.pyyaml
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    boost
    fstrm # Required for DNSTAP
    libbpf
    libcap
    libedit
    libsodium
    lua
    net-snmp
    nghttp2
    openssl
    re2
    systemd
    xdp-tools # AF_XDP support
    zlib
  ];

  configureFlags = [
    "--with-libsodium"
    "--with-re2"
    "--enable-dnscrypt"
    "--enable-dnstap"
    "--enable-dns-over-tls"
    "--enable-dns-over-https"
    "--enable-yaml"
    "--with-ebpf"
    "--with-xsk"
    "--with-libcap"
    "--with-protobuf=yes"
    "--with-net-snmp"
    "--disable-dependency-tracking"
    "--enable-unit-tests"
    "--enable-systemd"
    "--with-boost=${boost.dev}"
  ];

  doCheck = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) cargoRoot src;
    hash = "sha256-xFh+cywfNWalzRfCtM2pPtPfq8/RAlTC1EdZYYEiwxA=";
  };

  cargoRoot = "dnsdist-rust-lib/rust";
  enableParallelBuilding = true;
  passthru.tests = nixosTests.dnsdist;

  meta = {
    description = "DNS Loadbalancer";
    homepage = "https://dnsdist.org";
    changelog = "https://www.dnsdist.org/changelog.html";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ jojosch ];
    mainProgram = "dnsdist";
  };
})
