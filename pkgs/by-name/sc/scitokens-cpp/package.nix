{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  libuuid,
  openssl,
  pkg-config,
  sqlite,
}:

stdenv.mkDerivation {
  pname = "scitokens-cpp";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "scitokens";
    repo = "scitokens-cpp";
    rev = "v1.4.1";
    hash = "sha256-qZUW+b8drIAm21baUO1+O39O9FPP2McmdjsfGTRGRfQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libuuid
    openssl
    curl
    sqlite
  ];

  meta = {
    description = "C++ implementation of the SciTokens library with a C library interface";
    homepage = "https://github.com/scitokens/scitokens-cpp/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ evey ];
    platforms = lib.platforms.unix;
  };
}
