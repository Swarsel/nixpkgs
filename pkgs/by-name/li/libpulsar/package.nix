{
  lib,
  stdenv,
  fetchFromGitHub,
  asio_1_32_0,
  boost,
  boost186,
  cmake,
  curl,
  gtest,
  jsoncpp,
  log4cxx,
  openssl,
  pkg-config,
  protobuf_21,
  snappy,
  zlib,
  zstd,
  asioSupport ? true,
  gtestSupport ? false,
  log4cxxSupport ? false,
  snappySupport ? false,
  zlibSupport ? true,
  zstdSupport ? true,
}:

let
  protobuf = protobuf_21;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libpulsar";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "pulsar-client-cpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+gGddndiRot2kW7KGuKfWA85mh8e+9PetnEBQvfZB1I=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf # protoc
  ]
  ++ lib.optionals gtestSupport [
    (lib.getDev gtest)
  ];

  buildInputs = [
    curl
    jsoncpp
    openssl
    protobuf
  ]
  ++ lib.optionals snappySupport [
    (lib.getDev snappy)
  ]
  ++ lib.optionals zlibSupport [
    zlib
  ]
  ++ lib.optionals zstdSupport [
    zstd
  ]
  ++ lib.optionals log4cxxSupport [
    log4cxx
  ]
  ++ lib.optionals asioSupport [
    # io_service was removed in 1.33.0
    asio_1_32_0
    boost
  ]
  ++ lib.optionals (!asioSupport) [
    # io_service was removed in 1.87.0
    boost186
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTS" gtestSupport)
    (lib.cmakeBool "USE_LOG4CXX" log4cxxSupport)
    # We enable USE_ASIO here so at least we can
    # have newer boost minus boost::asio
    (lib.cmakeBool "USE_ASIO" asioSupport)
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    echo ${lib.escapeShellArg ''
      #include <pulsar/Client.h>
      int main (int argc, char **argv) {
        pulsar::Client client("pulsar://localhost:6650");
        return 0;
      }
    ''} > test.cc
    $CXX test.cc -L $out/lib -I $out/include -lpulsar -o test
  '';

  meta = {
    description = "Apache Pulsar C++ library";
    homepage = "https://pulsar.apache.org/docs/next/client-libraries-cpp/";
    changelog = "https://github.com/apache/pulsar-client-cpp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ corbanr ];
    platforms = lib.platforms.all;
  };
})
