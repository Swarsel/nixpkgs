{
  lib,
  stdenv,
  fetchFromGitHub,
  avro-c,
  libserdes,
  pkg-config,
  rdkafka,
  which,
  yajl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kcat";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "edenhill";
    repo = "kcat";
    rev = finalAttrs.version;
    sha256 = "sha256-pCIYNx0GYPGDYzTLq9h/LbOrJjhKWLAV4gq07Ikl5O4=";
  };

  nativeBuildInputs = [
    pkg-config
    which
  ];

  buildInputs = [
    zlib
    rdkafka
    yajl
    avro-c
    libserdes
  ];

  meta = {
    description = "Generic non-JVM producer and consumer for Apache Kafka";
    homepage = "https://github.com/edenhill/kcat";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nyarly ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "kcat";
  };
})
