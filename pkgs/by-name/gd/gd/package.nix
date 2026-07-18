{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  fetchpatch,
  fontconfig,
  freetype,
  libavif,
  libjpeg,
  libpng,
  libtiff,
  libwebp,
  libxpm,
  pkg-config,
  zlib,
  withXorg ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gd";
  version = "2.3.3";

  src = fetchurl {
    url = "https://github.com/libgd/libgd/releases/download/gd-${finalAttrs.version}/libgd-${finalAttrs.version}.tar.xz";
    sha256 = "0qas3q9xz3wgw06dm2fj0i189rain6n60z1vyq50d5h7wbn25s1z";
  };

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  patches = [
    (fetchpatch {
      # included in > 2.3.3
      name = "restore-GD_FLIP.patch";
      sha256 = "XRXR3NOkbEub3Nybaco2duQk0n8vxif5mTl2AUacn9w=";
      url = "https://github.com/libgd/libgd/commit/f4bc1f5c26925548662946ed7cfa473c190a104a.diff";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  buildInputs = [
    zlib
    freetype
    libpng
    libjpeg
    libwebp
    libtiff
    libavif
  ]
  ++ lib.optionals withXorg [
    fontconfig
    libxpm
  ];

  configureFlags = [
    "--enable-gd-formats"
  ]
  # -pthread gets passed to clang, causing warnings
  ++ lib.optional stdenv.hostPlatform.isDarwin "--enable-werror=no";

  doCheck = false; # fails 2 tests
  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "Dynamic image creation library";
    homepage = "https://libgd.github.io/";
    license = lib.licenses.free; # some custom license
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
