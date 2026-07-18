{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cmake,
  fetchpatch2,
  fuse,
  icu,
  libiconv,
  libxml2,
  lzfse,
  nixosTests,
  openssl,
  zlib,
}:

stdenv.mkDerivation {
  pname = "darling-dmg";
  version = "1.0.4-unstable-2023-07-26";

  src = fetchFromGitHub {
    owner = "darlinghq";
    repo = "darling-dmg";
    rev = "a36bf0c07b16675b446377890c5f6f74563f84dd";
    hash = "sha256-QM75GuFHl2gRlRw1BmTexUE1d9YNnhG0qmTqmE9kMX4=";
  };

  patches = [
    # Fix compilation
    (fetchpatch2 {
      hash = "sha256-i1lisEiwYm4IxgKmBYnjscvW6ObT7XGLVbjW2i5yXV4=";
      name = "cmake-cxx-standard-17.patch";
      url = "https://github.com/darlinghq/darling-dmg/pull/105/commits/b7c620f76a5f76748b3d14dd2a58e77f8b6ed0c0.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    fuse
    openssl
    zlib
    bzip2
    libxml2
    icu
    lzfse
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  env.CXXFLAGS = toString [
    "-DCOMPILE_WITH_LZFSE=1"
    "-llzfse"
  ];

  passthru.tests = {
    inherit (nixosTests) darling-dmg;
  };

  meta = {
    description = "FUSE module for .dmg files (containing an HFS+ filesystem)";
    homepage = "https://www.darlinghq.org/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Luflosi ];
    platforms = lib.platforms.unix;
    mainProgram = "darling-dmg";
  };
}
