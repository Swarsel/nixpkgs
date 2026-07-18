{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  curl,
  gengetopt,
  libiconv,
  libtool,
  libxml2,
  opensp,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libofx";
  version = "0.10.9";

  src = fetchFromGitHub {
    owner = "LibOFX";
    repo = "libofx";
    rev = finalAttrs.version;
    sha256 = "sha256-KOQrEAt1jHrOpPQ7QbGUADe0i7sQXNH2fblPRzT0EIg=";
  };

  nativeBuildInputs = [
    pkg-config
    libtool
    autoconf
    automake
    gengetopt
  ];

  buildInputs = [
    opensp
    libxml2
    curl
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;

  configureFlags = [ "--with-opensp-includes=${opensp}/include/OpenSP" ];
  preConfigure = "./autogen.sh";

  meta = {
    description = "Opensource implementation of the Open Financial eXchange specification";
    homepage = "https://libofx.sourceforge.net/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
