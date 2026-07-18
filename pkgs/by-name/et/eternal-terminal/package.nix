{
  lib,
  stdenv,
  fetchFromGitHub,
  catch2,
  cmake,
  gflags,
  libsodium,
  openssl,
  protobuf,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eternal-terminal";
  version = "6.2.11";

  src = fetchFromGitHub {
    owner = "MisterTea";
    repo = "EternalTerminal";
    tag = "et-v${finalAttrs.version}";
    hash = "sha256-d3mCZQO12NUQjGIOX1FWTLUq+adMTNb9QYCSU3ibZMY=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gflags
    libsodium
    openssl
    protobuf
    zlib
  ];

  cmakeFlags = [
    "-DDISABLE_VCPKG=TRUE"
    "-DDISABLE_SENTRY=TRUE"
    "-DDISABLE_CRASH_LOG=TRUE"
  ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    CXXFLAGS = toString [ "-std=c++17" ];
  };

  preBuild = ''
    mkdir -p ../external_imported/Catch2/single_include/catch2
    cp ${catch2}/include/catch2/catch.hpp ../external_imported/Catch2/single_include/catch2/catch.hpp
  '';

  doCheck = true;

  meta = {
    description = "Remote shell that automatically reconnects without interrupting the session";
    homepage = "https://eternalterminal.dev/";
    changelog = "https://github.com/MisterTea/EternalTerminal/releases/tag/et-v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jshort
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
