{
  lib,
  stdenv,
  fetchgit,
  gnutls,
  nettle,
  openssl,
  zlib,
  gnutlsSupport ? false,
  opensslSupport ? true,
}:

assert (gnutlsSupport || opensslSupport);

stdenv.mkDerivation {
  pname = "rtmpdump";
  version = "2.6";

  src = fetchgit {
    url = "git://git.ffmpeg.org/rtmpdump";
    # Releases are not tagged.
    rev = "6f6bb1353fc84f4cc37138baa99f586750028a01";
    hash = "sha256-rwMA9eougKnkpG+fe6vZIwOBt2CC1d9qI9a079EbE5o=";
  };

  outputs = [
    "out"
    "dev"
  ];

  propagatedBuildInputs = [
    zlib
  ]
  ++ lib.optionals gnutlsSupport [
    gnutls
    nettle
  ]
  ++ lib.optional opensslSupport openssl;

  makeFlags = [
    "prefix=$(out)"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ]
  ++ lib.optional gnutlsSupport "CRYPTO=GNUTLS"
  ++ lib.optional opensslSupport "CRYPTO=OPENSSL"
  ++ lib.optional stdenv.hostPlatform.isDarwin "SYS=darwin";

  preBuild = ''
    makeFlagsArray+=(CC="$CC")
  '';

  separateDebugInfo = true;

  meta = {
    description = "Toolkit for RTMP streams";
    homepage = "https://rtmpdump.mplayerhq.hu/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
