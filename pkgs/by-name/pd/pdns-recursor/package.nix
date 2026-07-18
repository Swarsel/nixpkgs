{
  lib,
  stdenv,
  fetchurl,
  boost,
  cargo,
  curl,
  libsodium,
  lua,
  luajit,
  nixosTests,
  openssl,
  pkg-config,
  protobuf,
  python3,
  rustPlatform,
  rustc,
  systemd,
  enableProtoBuf ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pdns-recursor";
  version = "5.4.3";

  src = fetchurl {
    url = "https://downloads.powerdns.com/releases/pdns-recursor-${finalAttrs.version}.tar.xz";
    hash = "sha256-opICnFQ6xFOMpXYouBQsntypsoOjqAyzk+2UfgWE8A8=";
  };

  nativeBuildInputs = [
    cargo
    rustc
    python3
    rustPlatform.cargoSetupHook
    pkg-config
  ];

  buildInputs = [
    boost
    openssl
    systemd
    lua
    luajit
    libsodium
    curl
  ]
  ++ lib.optional enableProtoBuf protobuf;

  configureFlags = [
    "--enable-reproducible"
    "--enable-systemd"
    "--enable-dns-over-tls"
    "--with-boost=${boost.dev}"
    "sysconfdir=/etc/pdns-recursor"
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-eAiXdsHWZca0wx5FONGfa7JDcpDHyCABJOUROhwAsZo=";
    sourceRoot = "pdns-recursor-${finalAttrs.version}/rec-rust-lib/rust";
  };

  cargoRoot = "rec-rust-lib/rust";
  enableParallelBuilding = true;
  installFlags = [ "sysconfdir=$(out)/etc/pdns-recursor" ];

  passthru.tests = {
    inherit (nixosTests) pdns-recursor ncdns;
  };

  meta = {
    description = "Recursive DNS server";
    homepage = "https://www.powerdns.com/";
    changelog = "https://doc.powerdns.com/recursor/changelog/${lib.versions.majorMinor finalAttrs.version}.html#change-${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.linux;

    badPlatforms = [
      "i686-linux" # a 64-bit time_t is needed
    ];
  };
})
