{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gmp,
  openssl,
  pkg-config,
  enableStatic ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libff";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "scipr-lab";
    repo = "libff";
    tag = "v${finalAttrs.version}";
    sha256 = "0dczi829497vqlmn6n4fgi89bc2h9f13gx30av5z2h6ikik7crgn";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace "VERSION 2.8" "VERSION 3.10"
  ''
  + lib.optionalString (!enableStatic) ''
    substituteInPlace libff/CMakeLists.txt --replace "STATIC" "SHARED"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    gmp
    openssl
  ];

  cmakeFlags = [
    "-DWITH_PROCPS=Off"
  ]
  ++ lib.optionals stdenv.hostPlatform.isAarch64 [
    "-DCURVE=ALT_BN128"
    "-DUSE_ASM=OFF"
  ];

  meta = {
    description = "C++ library for Finite Fields and Elliptic Curves";
    homepage = "https://github.com/scipr-lab/libff";
    changelog = "https://github.com/scipr-lab/libff/blob/develop/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arturcygan ];
    platforms = lib.platforms.unix;
  };
})
