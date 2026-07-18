{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libevent,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcouchbase";
  version = "3.3.18";

  src = fetchFromGitHub {
    owner = "couchbase";
    repo = "libcouchbase";
    rev = finalAttrs.version;
    sha256 = "sha256-+6RrApyml/FPv8pRjmwY1yuZIX1YXNKqdeNjP1y4cbU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libevent
    openssl
  ];

  cmakeFlags = [ "-DLCB_NO_MOCK=ON" ];
  doCheck = !stdenv.hostPlatform.isDarwin;
  # Running tests in parallel does not work
  enableParallelChecking = false;

  meta = {
    description = "C client library for Couchbase";
    homepage = "https://github.com/couchbase/libcouchbase";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
})
