{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cmake,
  gtest,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sexpp";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "rnpgp";
    repo = "sexpp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-T1qhwMBbz43URzdKPYMAbLSNrg4EaeKj4f9nqZsXls4=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    gtest
    pkg-config
  ];

  buildInputs = [
    zlib
    bzip2
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DBUILD_SHARED_LIBS=on"
    "-DWITH_SEXP_TESTS=on"
    "-DDOWNLOAD_GTEST=off"
    "-DWITH_SEXP_CLI=on"
    "-DWITH_SANITIZERS=off"
  ];

  preConfigure = ''
    echo "v${finalAttrs.version}" > version.txt
  '';

  meta = {
    description = "S-expressions parser and generator C++ library, fully compliant to [https://people.csail.mit.edu/rivest/Sexp.txt]";
    homepage = "https://github.com/rnpgp/sexp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ribose-jeffreylau ];
    platforms = lib.platforms.all;
    mainProgram = "sexpp";
  };
})
