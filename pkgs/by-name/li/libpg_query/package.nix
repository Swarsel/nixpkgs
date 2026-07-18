{
  lib,
  stdenv,
  fetchFromGitHub,
  protobufc,
  squawk,
  which,
  xxhash,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libpg_query";
  version = "18.0.0";

  src = fetchFromGitHub {
    owner = "pganalyze";
    repo = "libpg_query";
    tag = finalAttrs.version;
    hash = "sha256-Fs9SFs8ramKYdkv1gEOMJd9SnLmKDcbf+zYKv1hHBfc=";
  };

  nativeBuildInputs = [ which ];

  makeFlags = [
    "build"
    "build_shared"
  ];

  doCheck = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 libpg_query.a -t $out/lib
    install -Dm644 libpg_query${stdenv.hostPlatform.extensions.sharedLibrary} -t $out/lib
    cp -r src/include $out/include
    cp -r src/postgres/include/* $out/include
    cp -r protobuf $out/include/protobuf
    ln -s ${protobufc.dev}/include/protobuf-c $out/include/protobuf-c
    cp -r ${protobufc.dev}/include/protobuf-c/* $out/include
    ln -s ${xxhash}/include $out/include/xxhash
    install -Dm644 pg_query.h -t $out/include

    runHook postInstall
  '';

  checkTarget = "test";

  passthru.tests = {
    inherit squawk;
  };

  meta = {
    description = "C library for accessing the PostgreSQL parser outside of the server environment";
    homepage = "https://github.com/pganalyze/libpg_query";
    changelog = "https://github.com/pganalyze/libpg_query/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
