{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  # for passthru.tests
  dvgrab,
  epeg,
  gd,
  graphicsmagick,
  imagemagick,
  imlib2,
  jhead,
  libjxl,
  mjpegtools,
  nasm,
  nix-update-script,
  opencv,
  openjdk,
  python3,
  testers,
  vips,
  enableJava ? false, # whether to build the java wrapper
  enableJpeg7 ? false, # whether to build libjpeg with v7 compatibility
  enableJpeg8 ? false, # whether to build libjpeg with v8 compatibility
  enableShared ? !stdenv.hostPlatform.isStatic,
  enableStatic ? stdenv.hostPlatform.isStatic,
}:

assert !(enableJpeg7 && enableJpeg8); # pick only one or none, not both

stdenv.mkDerivation (finalAttrs: {
  pname = "libjpeg-turbo";
  version = "3.1.4.1";

  src = fetchFromGitHub {
    owner = "libjpeg-turbo";
    repo = "libjpeg-turbo";
    tag = finalAttrs.version;
    hash = "sha256-jBajigX4/j4jG11prTPeGkTVRrRzheFL/LxgnPufzb4=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "man"
    "doc"
  ];

  patches =
    [ ]
    ++ lib.optionals stdenv.hostPlatform.isMinGW [
      ./mingw-boolean.patch
    ];

  nativeBuildInputs = [
    cmake
    nasm
  ]
  ++ lib.optionals enableJava [
    openjdk
  ];

  cmakeFlags = [
    "-DENABLE_STATIC=${if enableStatic then "1" else "0"}"
    "-DENABLE_SHARED=${if enableShared then "1" else "0"}"
  ]
  ++ lib.optionals enableJava [
    "-DWITH_JAVA=1"
  ]
  ++ lib.optionals enableJpeg7 [
    "-DWITH_JPEG7=1"
  ]
  ++ lib.optionals enableJpeg8 [
    "-DWITH_JPEG8=1"
  ]
  ++ lib.optionals stdenv.hostPlatform.isRiscV [
    # https://github.com/libjpeg-turbo/libjpeg-turbo/issues/428
    # https://github.com/libjpeg-turbo/libjpeg-turbo/commit/88bf1d16786c74f76f2e4f6ec2873d092f577c75
    "-DFLOATTEST=fp-contract"
  ];

  doInstallCheck = true;
  installCheckTarget = "test";

  passthru = {
    dev_private = throw "not supported anymore";

    tests = {
      inherit
        dvgrab
        epeg
        gd
        graphicsmagick
        imagemagick
        imlib2
        jhead
        libjxl
        mjpegtools
        opencv
        vips
        ;

      inherit (python3.pkgs) pillow imread pyturbojpeg;
      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Faster (using SIMD) libjpeg implementation";
    homepage = "https://libjpeg-turbo.org/";
    changelog = "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/tag/${finalAttrs.version}";
    license = lib.licenses.ijg; # and some parts under other BSD-style licenses

    maintainers = with lib.maintainers; [
      vcunat
      kamadorueda
    ];

    platforms = lib.platforms.all;

    pkgConfigModules = [
      "libjpeg"
      "libturbojpeg"
    ];
  };
})
