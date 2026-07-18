{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  libevent,
  libnet,
  libpcap,
  openssl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sslsplit";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "droe";
    repo = "sslsplit";
    rev = finalAttrs.version;
    sha256 = "1p43z9ln5rbc76v0j1k3r4nhvfw71hq8jzsallb54z9hvwfvqp3l";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-sEwP7f2PSqXdMqLub9zrfQgH8I4oe9klVPzNpJjrPJ8=";
      name = "fix-openssl-3-build.patch";
      url = "https://github.com/droe/sslsplit/commit/e17de8454a65d2b9ba432856971405dfcf1e7522.patch";
    })
  ];

  buildInputs = [
    openssl
    libevent
    libpcap
    libnet
    zlib
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "OPENSSL_BASE=${lib.getDev openssl}"
    "LIBEVENT_BASE=${lib.getDev libevent}"
    "LIBPCAP_BASE=${lib.getDev libpcap}"
    "LIBNET_BASE=${lib.getDev libnet}"
  ];

  meta = {
    description = "Transparent SSL/TLS interception";
    homepage = "https://www.roe.ch/SSLsplit";

    license = with lib.licenses; [
      bsd2
      mit
      unlicense
      free
    ];

    maintainers = with lib.maintainers; [ contrun ];
    platforms = lib.platforms.all;
    mainProgram = "sslsplit";
  };
})
