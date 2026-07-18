{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  autoconf,
  automake,
  doxygen,
  gnutls,
  libtool,
  pkg-config,
  which,
  withDocs ? true,
  withTLS ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libcoap";
  version = "4.3.5a";

  src = fetchFromGitHub {
    owner = "obgm";
    repo = "libcoap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mLVGIG2JkWMlnZOlLxFTZVGM0nF6q2PKJoEo0s4Vq54=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    automake
    autoconf
    which
    libtool
    pkg-config
  ]
  ++ lib.optional withTLS gnutls
  ++ lib.optionals withDocs [
    doxygen
    asciidoc
  ];

  configureFlags = [
    "--disable-shared"
  ]
  ++ lib.optional (!withDocs) "--disable-documentation"
  ++ lib.optional withTLS "--enable-dtls";

  preConfigure = "./autogen.sh";

  meta = {
    description = "CoAP (RFC 7252) implementation in C";
    homepage = "https://github.com/obgm/libcoap";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.kmein ];
    platforms = lib.platforms.unix;
  };
})
