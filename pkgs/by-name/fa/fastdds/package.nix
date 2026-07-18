{
  lib,
  stdenv,
  fetchFromGitHub,
  asio,
  cmake,
  fastcdr,
  foonathan-memory,
  openjdk11,
  openssl,
  pkg-config,
  python3,
  tinyxml-2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastdds";
  version = "3.6.2";

  src = fetchFromGitHub {
    owner = "eProsima";
    repo = "Fast-DDS";
    rev = "v${finalAttrs.version}";
    hash = "sha256-17AxZwYPBhl+AyehWvNYP/if124GcmNfWJOD/yB+tgk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    openjdk11
    pkg-config
  ];

  buildInputs = [
    openssl
    asio
    tinyxml-2
    foonathan-memory
    fastcdr
    python3
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=ON"
    "-DSECURITY=ON"
    "-DCOMPILE_EXAMPLES=OFF"
    "-DCMAKE_PREFIX_PATH=${foonathan-memory}"
  ];

  meta = {
    description = "C++ implementation of the DDS (Data Distribution Service) standard";

    longDescription = ''
      eProsima Fast DDS is a C++ implementation of the DDS (Data Distribution Service) standard
      of the OMG (Object Management Group). It implements the RTPS (Real Time Publish Subscribe)
      protocol, which provides publisher-subscriber communications over unreliable transports
      such as UDP, as defined and maintained by the Object Management Group (OMG) consortium.
    '';

    homepage = "https://github.com/eProsima/Fast-DDS";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      panicgh
    ];

    platforms = lib.platforms.linux;
  };
})
