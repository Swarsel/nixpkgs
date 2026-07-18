{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "OpenCorsairLink";
  version = "0-unstable-2019-12-23";

  src = fetchFromGitHub {
    owner = "audiohacked";
    repo = "OpenCorsairLink";
    rev = "46dbf206e19a40d6de6bd73142ed93bdb26c5c1a";
    sha256 = "1nizicl0mc9pslc6065mnrs0fnn8sh7ca8iiw7w9ix57zrhabpld";
  };

  patches = [
    # Pull upstream fix for -fno-common toolchain
    (fetchpatch {
      name = "fno-common.patch";
      sha256 = "030rwka5bvf79x6ir18vqb09izhz1crp94x5gqjxwv3b20vvv4kx";
      url = "https://github.com/audiohacked/OpenCorsairLink/commit/d600c7ff032a3911d30b039844a31f0b3acfe26a.patch";
    })
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  # Fix GCC 14 build.
  # from incompatible pointer type [-Wincompatible-pointer-types]
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  meta = {
    description = "Linux and Mac OS support for the CorsairLink Devices";
    homepage = "https://github.com/audiohacked/OpenCorsairLink";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "OpenCorsairLink.elf";
  };
}
