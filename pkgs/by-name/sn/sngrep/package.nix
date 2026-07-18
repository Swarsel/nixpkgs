{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libgcrypt,
  libpcap,
  ncurses,
  openssl,
  pcre2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sngrep";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "irontec";
    repo = "sngrep";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4DLbQ3OOMvJw37n3jVuztG49HlPbWrfxByi6g6AvELQ=";
  };

  patches = [
    ./fix-sng_strncpy-declaration.patch
  ];

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  buildInputs = [
    libgcrypt
    libpcap
    ncurses
    openssl
    pcre2
  ];

  configureFlags = [
    "--with-pcre2"
    "--enable-unicode"
    "--enable-ipv6"
    "--enable-eep"
    "--with-openssl"
  ];

  preConfigure = ''
    ./bootstrap.sh
  '';

  doCheck = true;

  meta = {
    description = "Tool for displaying SIP calls message flows from terminal";
    homepage = "https://github.com/irontec/sngrep";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ jorise ];
    platforms = lib.platforms.unix;
    mainProgram = "sngrep";
  };
})
