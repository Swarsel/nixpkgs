{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  cargo,
  check,
  cmake,
  curl,
  json_c,
  libiconv,
  libmilter,
  libmspack,
  libxml2,
  ncurses,
  openssl,
  pcre2,
  pkg-config,
  python3,
  rust-bindgen,
  rustc,
  rustfmt,
  systemd,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clamav";
  version = "1.5.2";

  src = fetchurl {
    url = "https://www.clamav.net/downloads/production/clamav-${finalAttrs.version}.tar.gz";
    hash = "sha256-80AYzyLwW92dGhV0ygcZPj4DDKUgUMPlwiDiOjIxSWU=";
  };

  patches = [
    ./sample-configuration-file-install-location.patch
    ./use-non-existent-file-with-proper-permissions.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    rustc
    rust-bindgen
    rustfmt
    cargo
    python3
  ];

  buildInputs = [
    zlib
    bzip2
    libxml2
    openssl
    ncurses
    curl
    libiconv
    libmilter
    pcre2
    libmspack
    json_c
    check
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux systemd;

  cmakeFlags = [
    "-DSYSTEMD_UNIT_DIR=${placeholder "out"}/lib/systemd"
    "-DAPP_CONFIG_DIRECTORY=/etc/clamav"
    "-DCVD_CERTS_DIRECTORY=${placeholder "out"}/share/clamav/certs"
  ];

  # Fails on darwin with sandboxing
  doCheck = !(stdenv.hostPlatform.isDarwin);

  checkInputs = [
    python3.pkgs.pytest
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Antivirus engine designed for detecting Trojans, viruses, malware and other malicious threats";
    homepage = "https://www.clamav.net";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      robberer
      qknight
    ];

    platforms = lib.platforms.unix;
  };
})
