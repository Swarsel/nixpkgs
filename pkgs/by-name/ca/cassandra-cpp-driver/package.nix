{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  libuv,
  openssl,
  pkg-config,
  zlib,
  examples ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cassandra-cpp-driver";
  version = "2.17.1";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "cassandra-cpp-driver";
    tag = finalAttrs.version;
    sha256 = "sha256-GuvmKHJknudyn7ahrn/8+kKUA4NW5UjCfkYoX3aTE+Q=";
  };

  patches = [
    # https://github.com/apache/cassandra-cpp-driver/pull/580
    (fetchpatch {
      hash = "sha256-hQhm2SYLd8uPC85/iOH3sEM2KvoIGwV+9NGIJFnZJhc=";
      name = "fix-cmake-version.patch";
      url = "https://github.com/apache/cassandra-cpp-driver/commit/a4061051bcdfa0a67117b546897552c38493d545.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    zlib
    libuv
    openssl.dev
  ];

  cmakeFlags =
    (lib.attrsets.mapAttrsToList
      (name: value: "-DCASS_BUILD_${name}:BOOL=${if value then "ON" else "OFF"}")
      {
        EXAMPLES = examples;
      }
    )
    ++ [ "-DLIBUV_INCLUDE_DIR=${lib.getDev libuv}/include" ];

  meta = {
    description = "DataStax CPP cassandra driver";

    longDescription = ''
      A modern, feature-rich and highly tunable C/C++ client
      library for Apache Cassandra 2.1+ using exclusively Cassandra’s
      binary protocol and Cassandra Query Language v3.
    '';

    homepage = "https://docs.datastax.com/en/developer/cpp-driver/";
    license = with lib.licenses; [ asl20 ];
    maintainers = [ lib.maintainers.npatsakula ];
    platforms = lib.platforms.x86_64;
  };
})
