{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  pkg-config,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libatasmart";
  version = "0.19";

  src = fetchurl {
    url = "https://0pointer.de/public/libatasmart-${finalAttrs.version}.tar.xz";
    sha256 = "138gvgdwk6h4ljrjsr09pxk1nrki4b155hqdzyr8mlk3bwsfmw31";
  };

  outputs = [
    "out"
    "dev"
    "bin"
    "doc"
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  meta = {
    description = "Library for querying ATA SMART status";
    homepage = "http://0pointer.de/blog/projects/being-smart.html";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.linux;
  };
})
