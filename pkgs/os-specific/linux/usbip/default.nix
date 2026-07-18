{
  lib,
  stdenv,
  autoconf,
  automake,
  hwdata,
  kernel,
  kernelOlder,
  libtool,
  udev,
}:

stdenv.mkDerivation {
  pname = "usbip-${kernel.pname}";
  version = kernel.version;
  src = kernel.src;

  patches =
    lib.optionals (kernelOlder "5.4") [
      # fixes build with gcc8
      ./fix-snprintf-truncation.patch
      # fixes build with gcc9
      ./fix-strncpy-truncation.patch
    ]
    ++ kernel.patches;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  buildInputs = [ udev ];
  configureFlags = [ "--with-usbids-dir=${hwdata}/share/hwdata/" ];
  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-error=address-of-packed-member" ];

  preConfigure = ''
    cd tools/usb/usbip
    ./autogen.sh
  '';

  meta = {
    description = "Allows to pass USB device from server to client over the network";
    homepage = "https://github.com/torvalds/linux/tree/master/tools/usb/usbip";

    license = with lib.licenses; [
      gpl2Only
      gpl2Plus
    ];

    platforms = lib.platforms.linux;
    broken = kernelOlder "4.10";
  };
}
