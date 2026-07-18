{
  lib,
  stdenv,
  fetchurl,
  bison,
  bzip2,
  cmake,
  nixosTests,
  openssl,
  python3,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "monetdb";
  version = "11.55.5";

  src = fetchurl {
    url = "https://dev.monetdb.org/downloads/sources/archive/MonetDB-${finalAttrs.version}.tar.bz2";
    hash = "sha256-u/Jukp09g8i/zcUA0vFqmTMvX4XcNPs/gIRInvZSHj0=";
  };

  postPatch = ''
    substituteInPlace cmake/monetdb-packages.cmake --replace \
      'get_os_release_info(LINUX_DISTRO LINUX_DISTRO_VERSION)' \
      'set(LINUX_DISTRO "nixos")'
  '';

  nativeBuildInputs = [
    bison
    cmake
    python3
  ];

  buildInputs = [
    openssl
    readline
    bzip2
  ];

  postInstall = ''
    rm $out/bin/monetdb_mtest.sh \
      $out/bin/mktest.py \
      $out/bin/sqlsample.php \
      $out/bin/sqllogictest.py \
      $out/bin/Mz.py \
      $out/bin/Mtest.py \
      $out/bin/sqlsample.pl \
      $out/bin/malsample.pl
  '';

  passthru.tests = { inherit (nixosTests) monetdb; };

  meta = {
    description = "Open source database system";
    homepage = "https://www.monetdb.org/";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.StillerHarpo ];
    platforms = lib.platforms.unix;
  };
})
