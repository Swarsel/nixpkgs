{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  avahi,
  bison,
  cppunit,
  fetchpatch,
  flex,
  libftdi1,
  libmicrohttpd,
  libuuid,
  perl,
  pkg-config,
  protobuf_21,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ola";
  version = "0.10.9";

  src = fetchFromGitHub {
    owner = "OpenLightingProject";
    repo = "ola";
    tag = finalAttrs.version;
    hash = "sha256-8w8ZT3D/+8Pxl9z2KTXeydVxE5xiPjxZevgmMFgrblU=";
  };

  patches = [
    # Fix build error with GCC 14 due to stricter C++20 compliance (template-id in constructors)
    (fetchpatch {
      hash = "sha256-BplSqQv8ztWMpiX/M3/3wvf6LsPTBglh48gHlUoM6rw=";
      url = "https://github.com/OpenLightingProject/ola/commit/d9b9c78645c578adb7c07b692842e841c48310be.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    pkg-config
    perl
  ];

  buildInputs = [
    # required for ola-ftdidmx plugin (support for 'dumb' FTDI devices)
    libftdi1
    libuuid
    cppunit
    protobuf_21
    zlib
    avahi
    libmicrohttpd
    python3
  ];

  propagatedBuildInputs = [
    (python3.pkgs.protobuf4.override { protobuf = protobuf_21; })
    python3.pkgs.numpy
  ];

  configureFlags = [ "--enable-python-libs" ];
  enableParallelBuilding = true;

  meta = {
    description = "Framework for controlling entertainment lighting equipment";
    homepage = "https://www.openlighting.org/ola/";

    license = with lib.licenses; [
      lgpl21
      gpl2Plus
    ];

    maintainers = [ ];
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
