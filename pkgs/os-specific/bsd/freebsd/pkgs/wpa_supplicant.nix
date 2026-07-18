{
  libpcap,
  mkDerivation,
  openssl,
}:
mkDerivation {
  buildInputs = [
    libpcap
    openssl
  ];

  extraPaths = [
    "contrib/wpa"
  ];

  path = "usr.sbin/wpa";
}
