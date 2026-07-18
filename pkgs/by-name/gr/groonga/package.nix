{
  lib,
  stdenv,
  fetchurl,
  cmake,
  kytea,
  libevent,
  lz4,
  mecab,
  msgpack-c,
  pkg-config,
  postgresqlPackages,
  rapidjson,
  testers,
  xxhash,
  zeromq,
  zlib,
  zstd,
  lz4Support ? false,
  suggestSupport ? false,
  zlibSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "groonga";
  version = "15.2.3";

  src = fetchurl {
    url = "https://packages.groonga.org/source/groonga/groonga-${finalAttrs.version}.tar.gz";
    hash = "sha256-DwLNXhq/adrajX2HX0Cpr6UBT8yMDWRfa/sYDnGOpnI=";
  };

  patches = [
    ./fix-cmake-install-path.patch
    ./do-not-use-vendored-libraries.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    rapidjson
    xxhash
    zstd
    mecab
    kytea
    msgpack-c
  ]
  ++ lib.optionals lz4Support [
    lz4
  ]
  ++ lib.optionals zlibSupport [
    zlib
  ]
  ++ lib.optionals suggestSupport [
    zeromq
    libevent
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString zlibSupport "-I${zlib.dev}/include";

  passthru.tests = {
    inherit (postgresqlPackages) pgroonga;

    version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    pkg-config = testers.hasPkgConfigModules {
      moduleNames = [ "groonga" ];
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Open-source fulltext search engine and column store";

    longDescription = ''
      Groonga is an open-source fulltext search engine and column store.
      It lets you write high-performance applications that requires fulltext search.
    '';

    homepage = "https://groonga.org/";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
