{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  bzip2,
  c-blosc2,
  capnproto,
  catch2_3,
  clang-tools,
  cmake,
  curl,
  doxygen,
  file,
  fixDarwinDylibNames,
  gtest,
  libpng,
  lz4,
  nlohmann_json,
  onetbb,
  openssl,
  python3,
  rapidcheck,
  runCommand,
  spdlog,
  zlib,
  zstd,
  useAVX2 ? stdenv.hostPlatform.avx2Support,
}:

let
  rapidcheck' = runCommand "rapidcheck" { } ''
    cp -r ${rapidcheck.out} $out
    chmod -R +w $out
    cp -r ${rapidcheck.dev}/* $out
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tiledb";
  version = "2.30.0";

  src = fetchFromGitHub {
    owner = "TileDB-Inc";
    repo = "TileDB";
    tag = finalAttrs.version;
    hash = "sha256-wzeWLwwsZXtrKsmlglZG7YvIki/ba7IwsDBq+40ltcg=";
  };

  patches = [ ./0001-fix-cross-compilation-with-capnproto.patch ];

  postPatch = ''
    substituteInPlace tiledb/sm/misc/test/unit_parse_argument.cc \
      --replace-fail '"catch.hpp"' '<catch2/catch_all.hpp>'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    capnproto
    clang-tools
    cmake
    python3
    doxygen
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = [
    boost
    bzip2
    c-blosc2
    capnproto
    catch2_3
    curl
    file
    libpng
    lz4
    nlohmann_json
    onetbb
    openssl
    rapidcheck'
    spdlog
    zlib
    zstd
  ];

  # (bundled) blosc headers have a warning on some archs that it will be using
  # unaccelerated routines.
  cmakeFlags = [
    "-DTILEDB_WEBP=OFF"
    "-DTILEDB_WERROR=OFF"
    "-DTILEDB_SERIALIZATION=ON"
    # https://github.com/NixOS/nixpkgs/issues/144170
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ]
  ++ lib.optional (!useAVX2) "-DCOMPILER_SUPPORTS_AVX2=FALSE";

  env.TILEDB_DISABLE_AUTO_VCPKG = "1";

  preBuild = ''
    cmake --build . --target update-serialization
  '';

  nativeCheckInputs = [
    gtest
  ];

  # test commands taken from
  # https://github.com/TileDB-Inc/TileDB/blob/dev/.github/workflows/unit-test-runs.yml
  checkPhase = ''
    runHook preCheck

    pushd ..
    cmake --build build --target tests
    ctest --test-dir build -R '(^unit_|test_assert)' --no-tests=error
    ctest --test-dir build -R 'test_ci_asserts'
    popd

    runHook postCheck
  '';

  installTargets = [
    "install-tiledb"
    "doc"
  ];

  meta = {
    description = "Allows you to manage massive dense and sparse multi-dimensional array data";
    homepage = "https://github.com/TileDB-Inc/TileDB";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rakesh4g ];
    platforms = lib.platforms.unix;
  };
})
