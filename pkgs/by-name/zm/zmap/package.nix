{
  lib,
  stdenv,
  fetchFromGitHub,
  byacc,
  cmake,
  flex,
  gengetopt,
  gmp,
  json_c,
  judy,
  libjson,
  libpcap,
  libunistring,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zmap";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "zmap";
    repo = "zmap";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Mym0pyd43pcbnZzPW3P+N5syjTJBuMsH2ZsjOJmqZgA=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    gengetopt
    flex
    byacc
  ];

  buildInputs = [
    libjson
    json_c
    gmp
    libpcap
    libunistring
    judy
  ];

  cmakeFlags = [ "-DRESPECT_INSTALL_PREFIX_CONFIG=ON" ];

  meta = {
    description = "Fast single packet network scanner designed for Internet-wide network surveys";
    homepage = "https://zmap.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ma27 ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
