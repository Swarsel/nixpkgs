{
  lib,
  fetchurl,
  boost,
  cctools,
  clangStdenv,
  curl,
  icu,
  jemalloc,
  m4,
  makeWrapper,
  openssl,
  protobuf_21,
  python3Packages,
  which,
  zlib,
}:
let
  stdenv = clangStdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rethinkdb";
  version = "2.4.4";

  src = fetchurl {
    url = "https://download.rethinkdb.com/repository/raw/dist/rethinkdb-${finalAttrs.version}.tgz";
    hash = "sha256-UJEjdgK2KDDbLLParKarNGMjI3QeZxDC8N5NhPRCcR8=";
  };

  postPatch = ''
    substituteInPlace external/quickjs_*/Makefile \
      --replace "gcc-ar" "${stdenv.cc.targetPrefix}ar" \
      --replace "gcc" "${stdenv.cc.targetPrefix}cc"
  '';

  nativeBuildInputs = [
    which
    m4
    python3Packages.python
    makeWrapper
  ];

  buildInputs = [
    protobuf_21
    boost
    zlib
    curl
    openssl
    icu
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) jemalloc
  ++ lib.optional stdenv.hostPlatform.isDarwin cctools;

  configureFlags = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    "--with-jemalloc"
    "--lib-path=${jemalloc}/lib"
  ];

  makeFlags = [ "rethinkdb" ];

  preConfigure = ''
    export ALLOW_WARNINGS=1
    patchShebangs .
  '';

  postInstall = ''
    wrapProgram $out/bin/rethinkdb \
      --prefix PATH ":" "${python3Packages.rethinkdb}/bin"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Open-source distributed database built with love";

    longDescription = ''
      RethinkDB is built to store JSON documents, and scale to
      multiple machines with very little effort. It has a pleasant
      query language that supports really useful queries like table
      joins and group by, and is easy to setup and learn.
    '';

    homepage = "https://rethinkdb.com";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      thoughtpolice
    ];

    platforms = lib.platforms.unix;
    mainProgram = "rethinkdb";
  };
})
