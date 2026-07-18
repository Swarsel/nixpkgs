{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  buildPackages,
  curl,
  gd,
  gettext,
  libexif,
  libgphoto2,
  libjpeg,
  libtool,
  libusb1,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libgphoto2";
  version = "2.5.34";

  src = fetchFromGitHub {
    owner = "gphoto";
    repo = "libgphoto2";
    tag = "v${version}";
    hash = "sha256-+yPpoIgyXL/Qp2C4ykSlUg2BheWjzTEi6wID6yCsP/s=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    libtool
    pkg-config
  ];

  buildInputs = [
    libjpeg
    libtool # for libltdl
    libusb1
    curl
    libxml2
    gd
  ];

  # These are mentioned in the Requires line of libgphoto's pkg-config file.
  propagatedBuildInputs = [ libexif ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  postInstall =
    let
      executablePrefix =
        if stdenv.buildPlatform == stdenv.hostPlatform then "$out" else buildPackages.libgphoto2;
    in
    ''
      mkdir -p $out/lib/udev/{rules.d,hwdb.d}
      ${executablePrefix}/lib/libgphoto2/print-camera-list \
          udev-rules version 201 group camera \
          >$out/lib/udev/rules.d/40-libgphoto2.rules
      ${executablePrefix}/lib/libgphoto2/print-camera-list \
          hwdb version 201 group camera \
          >$out/lib/udev/hwdb.d/20-gphoto.hwdb
    '';

  doInstallCheck = true;
  depsBuildBuild = [ pkg-config ];
  hardeningDisable = [ "format" ];

  meta = {
    description = "Library for accessing digital cameras";

    longDescription = ''
      This is the library backend for gphoto2. It contains the code for PTP,
      MTP, and other vendor specific protocols for controlling and transferring data
      from digital cameras.
    '';

    homepage = "http://www.gphoto.org/proj/libgphoto2/";
    changelog = "https://github.com/gphoto/libgphoto2/blob/${src.tag}/NEWS";
    # XXX: the homepage claims LGPL, but several src files are lgpl21Plus
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ jcumming ];
    platforms = with lib.platforms; unix;
  };
}
