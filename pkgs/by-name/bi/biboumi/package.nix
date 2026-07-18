{
  lib,
  stdenv,
  botan3,
  cmake,
  expat,
  fetchFromCodeberg,
  libiconv,
  libidn,
  libpq,
  libuuid,
  pkg-config,
  python3Packages,
  sqlite,
  systemd,
  udns,
  withIDN ? true,
  withPostgreSQL ? false,
  withSQLite ? true,
  withUDNS ? true,
}:

assert lib.assertMsg (
  withPostgreSQL || withSQLite
) "At least one Biboumi database provider required";

stdenv.mkDerivation {
  pname = "biboumi";
  version = "9.0-unstable-2025-10-27";

  src = fetchFromCodeberg {
    owner = "poezio";
    repo = "biboumi";
    rev = "61242c35bc825d58c9db4301b5696bc17428bf98";
    hash = "sha256-BZTqu2Qvfqag9pwymlGrItLbOXQf3VMKQS2+3pxlJbE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    python3Packages.sphinx
  ];

  buildInputs = [
    libuuid
    expat
    libiconv
    systemd
    botan3
  ]
  ++ lib.optional withIDN libidn
  ++ lib.optional withPostgreSQL libpq
  ++ lib.optional withSQLite sqlite
  ++ lib.optional withUDNS udns;

  cmakeFlags = [
    # Fix breakage with CMake 4
    "-DCMAKE_SKIP_RPATH=ON"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  buildFlags = [
    "all"
    "man"
  ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt --replace /etc/biboumi $out/etc/biboumi
  '';

  doCheck = true;

  meta = {
    description = "Modern XMPP IRC gateway";
    homepage = "https://codeberg.org/poezio/biboumi";
    license = lib.licenses.zlib;
    maintainers = [ lib.maintainers.woffs ];
    platforms = lib.platforms.unix;
    mainProgram = "biboumi";
  };
}
