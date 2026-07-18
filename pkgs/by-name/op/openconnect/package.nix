{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  gmp,
  gnutls,
  libxml2,
  openssl,
  p11-kit,
  pcsclite,
  pkg-config,
  stoken,
  vpnc-scripts,
  xdg-utils,
  zlib,
  useDefaultExternalBrowser ?
    stdenv.hostPlatform.isLinux && stdenv.buildPlatform == stdenv.hostPlatform, # xdg-utils doesn't cross-compile
  useOpenSSL ? false,
}:

stdenv.mkDerivation {
  pname = "openconnect";
  version = "9.12-unstable-2025-11-03";

  src = fetchFromGitLab {
    owner = "openconnect";
    repo = "openconnect";
    rev = "0dcdff87db65daf692dc323732831391d595d98d";
    hash = "sha256-AvowUEDkXvR+QkhJbZU759fZjIqj/mO8HjP2Ka3lH1U=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    gmp
    libxml2
    stoken
    zlib
    (if useOpenSSL then openssl else gnutls)
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    p11-kit
    pcsclite
  ]
  ++ lib.optional useDefaultExternalBrowser xdg-utils;

  configureFlags = [
    "--with-vpnc-script=${vpnc-scripts}/bin/vpnc-script"
    "--disable-nls"
    "--without-openssl-version-check"
  ];

  # Not finding iconv on Darwin
  env = {
    am_cv_func_iconv_works = "yes";
  };

  meta = {
    description = "VPN Client for Cisco's AnyConnect SSL VPN";
    homepage = "https://www.infradead.org/openconnect/";
    license = lib.licenses.lgpl21Only;

    maintainers = with lib.maintainers; [
      tricktron
      pentane
    ];

    platforms = lib.platforms.unix;
    mainProgram = "openconnect";
  };
}
