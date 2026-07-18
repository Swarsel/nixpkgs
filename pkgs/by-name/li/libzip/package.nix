{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  cmake,
  groff,
  openssl,
  perl,
  testers,
  xz,
  zlib,
  zstd,
  withBzip2 ? true,
  withLZMA ? true,
  withOpenssl ? false,
  withZstd ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libzip";
  version = "1.11.4";

  src = fetchurl {
    url = "https://libzip.org/download/libzip-${finalAttrs.version}.tar.gz";
    hash = "sha256-guny8kIfnXwkZrvDFzzQlZWojqN9sNVZqdCi3GDcci4=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    perl
    groff
  ];

  buildInputs =
    lib.optionals withLZMA [ xz ]
    ++ lib.optionals withBzip2 [ bzip2 ]
    ++ lib.optionals withOpenssl [ openssl ]
    ++ lib.optionals withZstd [ zstd ];

  propagatedBuildInputs = [ zlib ];
  # Don't build the regression tests because they don't build with
  # pkgsStatic and are not executed anyway.
  cmakeFlags = [ "-DBUILD_REGRESS=0" ];

  preCheck = ''
    # regress/runtest is a generated file
    patchShebangs regress
  '';

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "C library for reading, creating and modifying zip archives";
    homepage = "https://libzip.org/";
    changelog = "https://github.com/nih-at/libzip/blob/v${finalAttrs.version}/NEWS.md";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "libzip" ];
  };
})
