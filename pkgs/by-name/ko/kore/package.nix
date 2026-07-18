{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  fetchpatch,
  libpq,
  openssl,
  yajl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kore";
  version = "4.2.3";

  src = fetchFromGitHub {
    owner = "jorisvink";
    repo = "kore";
    rev = finalAttrs.version;
    sha256 = "sha256-p0M2P02xwww5EnT28VnEtj5b+/jkPW3YkJMuK79vp4k=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-uHTWiliM4m2i9/6GQQfnAo31XBXd/2+fzysPeNo2dQ0=";
      url = "https://github.com/jorisvink/kore/commit/978cb0ab79c9c939c35996f34f7d835f9c671831.patch";
    })
    (fetchpatch {
      hash = "sha256-xaiUOjBJPEgEwwuseXe6VbOTkOCKdQ5tuwDdL7DojHM=";
      url = "https://github.com/jorisvink/kore/commit/6122affe22bf676eed0f544e421c53699aa7a2e2.patch";
    })
  ];

  nativeBuildInputs = [
    libpq.pg_config
  ];

  buildInputs = [
    openssl
    curl
    libpq
    yajl
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "ACME=1"
    "CURL=1"
    "TASKS=1"
    "PGSQL=1"
    "JSONRPC=1"
    "DEBUG=1"
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    [
      "-Wno-error=deprecated-declarations"
    ]
    ++ lib.optionals stdenv.cc.isGNU [
      "-Wno-error=pointer-compare"
      "-Wno-error=discarded-qualifiers"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      "-Wno-error=incompatible-pointer-types-discards-qualifiers"
    ]
  );

  preBuild = ''
    make platform.h
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Easy to use web application framework for C";
    homepage = "https://kore.io";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ johnmh ];
    platforms = lib.platforms.all;
  };
})
