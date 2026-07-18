{
  lib,
  stdenv,
  fetchurl,
  boost,
  cmake,
  mysql84,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmysqlconnectorcpp";
  version = "9.7.0";

  src = fetchurl {
    url = "mirror://mysql/Connector-C++/mysql-connector-c++-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-mj3U/kQagZH3YRkuzccXwYpYocu245Yj3rtxlsMHWw4=";
  };

  postPatch = ''
    sed '/^cmake_minimum_required/Is/VERSION [0-9]\.[0-9]/VERSION 3.5/' \
      -i ./cdk/extra/protobuf/CMakeLists.txt \
      -i ./cdk/extra/lz4/CMakeLists.txt \
      -i ./cdk/extra/zstd/CMakeLists.txt
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    mysql84
  ];

  buildInputs = [
    boost
    openssl
    mysql84
  ];

  cmakeFlags = [
    # libmysqlclient is shared library
    "-DMYSQLCLIENT_STATIC_LINKING=false"
    # still needed for mysql-workbench
    "-DWITH_JDBC=true"
  ];

  meta = {
    description = "C++ library for connecting to mysql servers";
    homepage = "https://dev.mysql.com/downloads/connector/cpp/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.unix;
  };
})
