{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libsodium,
  openssl,
  protobuf,
  protobufc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnats";
  version = "3.11.0";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = "nats.c";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-W1WxaQ33K+N3AHCK3sQWTQo4sN57qW2ZuAGrj6JpgCU=";
  };

  outputs = [
    "out"
    "dev"
  ];

  # https://github.com/nats-io/nats.c/issues/542
  postPatch = ''
    substituteInPlace src/libnats.pc.in \
      --replace '$'{prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libsodium
    openssl
    protobuf
    protobufc
  ];

  postFixup = ''
    substituteInPlace $dev/lib/cmake/cnats/cnats-config.cmake \
      --replace-fail "_IMPORT_PREFIX \"$out\"" "_IMPORT_PREFIX \"$dev\""
  '';

  separateDebugInfo = true;

  meta = {
    description = "C API for the NATS messaging system";
    homepage = "https://github.com/nats-io/nats.c";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.unix;
  };
})
